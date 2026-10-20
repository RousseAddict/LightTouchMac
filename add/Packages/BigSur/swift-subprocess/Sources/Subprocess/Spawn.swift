// Starting, watching and stopping the child: posix_spawn with every descriptor but 0-2 closed in the child and the
// signals reset (as DeviceRuntime's ltm_spawn does), a thread that waits for the exit, and the teardown sequence.
import BigSurCompat
import Darwin
import Foundation
import System

/// A spawned child and this process's ends of its pipes.
struct Spawned {
    let pid: pid_t
    let stdinWrite: CInt?
    let stdoutRead: CInt?
    let stderrRead: CInt?
}

func spawn(
    _ executable: Executable,
    arguments: Arguments,
    environment: Environment,
    workingDirectory: FilePath?,
    input: _InputKind,
    output: _OutputKind,
    error: _OutputKind
) throws -> Spawned {
    var actions: posix_spawn_file_actions_t?
    posix_spawn_file_actions_init(&actions)
    defer { posix_spawn_file_actions_destroy(&actions) }
    var attributes: posix_spawnattr_t?
    posix_spawnattr_init(&attributes)
    defer { posix_spawnattr_destroy(&attributes) }
    var all = sigset_t()
    sigfillset(&all)
    var none = sigset_t()
    sigemptyset(&none)
    posix_spawnattr_setsigdefault(&attributes, &all)
    posix_spawnattr_setsigmask(&attributes, &none)
    posix_spawnattr_setflags(
        &attributes, Int16(POSIX_SPAWN_CLOEXEC_DEFAULT | POSIX_SPAWN_SETSIGDEF | POSIX_SPAWN_SETSIGMASK))

    var childEnds: [CInt] = []
    var parentEnds: [CInt] = []
    var closeAfterSpawn: Set<CInt> = []
    func makePipe() throws -> (read: CInt, write: CInt) {
        var fds: [CInt] = [-1, -1]
        guard pipe(&fds) == 0 else { throw SubprocessError.errno(.spawnFailed, "pipe") }
        for fd in fds { _ = fcntl(fd, F_SETFD, FD_CLOEXEC) }
        return (fds[0], fds[1])
    }
    func closeAll() {
        for fd in childEnds + parentEnds { close(fd) }
    }

    var stdinWrite: CInt?
    do {
        switch input {
        case .none:
            posix_spawn_file_actions_addopen(&actions, 0, "/dev/null", O_RDONLY, 0)
        case .writer:
            let ends = try makePipe()
            posix_spawn_file_actions_adddup2(&actions, ends.read, 0)
            childEnds.append(ends.read)
            parentEnds.append(ends.write)
            stdinWrite = ends.write
        }
        func route(_ kind: _OutputKind, to target: CInt) throws -> CInt? {
            switch kind {
            case .discarded:
                posix_spawn_file_actions_addopen(&actions, target, "/dev/null", O_WRONLY, 0)
                return nil
            case .collected, .sequence:
                let ends = try makePipe()
                posix_spawn_file_actions_adddup2(&actions, ends.write, target)
                childEnds.append(ends.write)
                parentEnds.append(ends.read)
                return ends.read
            case .fileDescriptor(let descriptor, let closeAfterSpawning):
                posix_spawn_file_actions_adddup2(&actions, descriptor.rawValue, target)
                if closeAfterSpawning { closeAfterSpawn.insert(descriptor.rawValue) }
                return nil
            }
        }
        let stdoutRead = try route(output, to: 1)
        let stderrRead = try route(error, to: 2)
        if let directory = workingDirectory {
            let status = directory.withCString { posix_spawn_file_actions_addchdir_np(&actions, $0) }
            guard status == 0 else { throw SubprocessError.errno(.spawnFailed, "chdir", status) }
        }

        let program: String
        switch executable.storage {
        case .path(let path): program = path
        case .name(let name): program = name
        }
        let argv = ([program] + arguments.storage).map { strdup($0) } + [nil]
        let envp = environment.resolved.map { strdup("\($0.key)=\($0.value)") } + [nil]
        defer {
            for pointer in argv + envp { free(pointer) }
        }
        var pid: pid_t = 0
        let status: CInt
        switch executable.storage {
        case .path(let path): status = posix_spawn(&pid, path, &actions, &attributes, argv, envp)
        case .name(let name): status = posix_spawnp(&pid, name, &actions, &attributes, argv, envp)
        }
        guard status == 0 else { throw SubprocessError.errno(.spawnFailed, "Couldn't run \(program)", status) }

        for fd in childEnds { close(fd) }
        for fd in closeAfterSpawn { close(fd) }
        return Spawned(pid: pid, stdinWrite: stdinWrite, stdoutRead: stdoutRead, stderrRead: stderrRead)
    } catch {
        closeAll()
        throw error
    }
}

/// Waits for the child on a thread of its own and reaps it. It first waits without reaping and marks the child
/// exited under the lock that teardown signals under, so a signal never reaches a reused PID.
final class ProcessWaiter: @unchecked Sendable {
    let pid: pid_t
    private let lock = NSLock()
    private var exited = false
    private var status: TerminationStatus?
    private var waiters: [CheckedContinuation<TerminationStatus, Never>] = []
    private let done = DispatchGroup()

    init(pid: pid_t) {
        self.pid = pid
        done.enter()
        let thread = Thread { [self] in
            var info = siginfo_t()
            while waitid(P_PID, id_t(pid), &info, WEXITED | WNOWAIT) != 0 && errno == EINTR {}
            lock.lock()
            exited = true
            lock.unlock()
            var raw: CInt = 0
            while waitpid(pid, &raw, 0) < 0 && errno == EINTR {}
            let ended = TerminationStatus(waitStatus: raw)
            lock.lock()
            status = ended
            let resumed = waiters
            waiters = []
            lock.unlock()
            for waiter in resumed { waiter.resume(returning: ended) }
            done.leave()
        }
        thread.name = "Subprocess.wait \(pid)"
        thread.start()
    }

    var hasExited: Bool {
        lock.lock()
        defer { lock.unlock() }
        return exited
    }

    func wait() async -> TerminationStatus {
        await withCheckedContinuation { continuation in
            lock.lock()
            if let status = status {
                lock.unlock()
                continuation.resume(returning: status)
            } else {
                waiters.append(continuation)
                lock.unlock()
            }
        }
    }

    /// Blocks until the child exits or `timeout` passes; true when it exited. Not for Swift concurrency threads.
    func blockUntilExit(timeout: CompatDuration) -> Bool {
        done.wait(timeout: .now() + .nanoseconds(Int(max(0, timeout.nanoseconds)))) == .success
    }

    /// Sends `signal` unless the child has exited.
    func send(_ signal: CInt) {
        lock.lock()
        defer { lock.unlock() }
        if !exited { kill(pid, signal) }
    }

    /// The teardown sequence, then SIGKILL, each step skipped once the child is gone; on a queue of its own, so
    /// it runs even when the task that asked for it is cancelled.
    func tearDown(_ steps: [TeardownStep]) {
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            for step in steps {
                if hasExited { return }
                send(step.signal.rawValue)
                if blockUntilExit(timeout: step.allowed) { return }
            }
            send(SIGKILL)
        }
    }
}

/// Reads a pipe on a thread of its own until the end of the output, or until the child has exited and nothing more
/// is waiting (a grandchild can keep the pipe open; 1.0.0 stops there too).
final class PipeReader: @unchecked Sendable {
    let stream: AsyncThrowingStream<Data, Swift.Error>

    init(descriptor: CInt, waiter: ProcessWaiter) {
        var continuation: AsyncThrowingStream<Data, Swift.Error>.Continuation!
        stream = AsyncThrowingStream(bufferingPolicy: .unbounded) { continuation = $0 }
        let output = continuation!
        let thread = Thread {
            defer { close(descriptor) }
            var buffer = [UInt8](repeating: 0, count: 64 * 1024)
            var draining = false
            while true {
                var poller = pollfd(fd: descriptor, events: Int16(POLLIN), revents: 0)
                let ready = poll(&poller, 1, draining ? 0 : 100)
                if ready < 0 {
                    if errno == EINTR { continue }
                    output.finish(throwing: SubprocessError.errno(.readFailed, "poll"))
                    return
                }
                if ready == 0 {
                    if draining {
                        output.finish()
                        return
                    }
                    draining = waiter.hasExited
                    continue
                }
                let count = buffer.withUnsafeMutableBytes { read(descriptor, $0.baseAddress, $0.count) }
                if count > 0 {
                    output.yield(Data(buffer[0..<count]))
                } else if count == 0 {
                    output.finish()
                    return
                } else if errno != EINTR && errno != EAGAIN {
                    output.finish(throwing: SubprocessError.errno(.readFailed, "read"))
                    return
                }
            }
        }
        thread.name = "Subprocess.read \(waiter.pid)"
        thread.start()
    }

    /// Everything read, failing with outputLimitExceeded past `limit` bytes (after reading to the end, so the
    /// child never blocks on a full pipe).
    func collect(limit: Int) async throws -> Data {
        var data = Data()
        var exceeded = false
        for try await chunk in stream {
            if exceeded { continue }
            data.append(chunk)
            if data.count > limit {
                exceeded = true
                data = Data()
            }
        }
        if exceeded { throw SubprocessError.outputLimitExceeded(limit: limit) }
        return data
    }
}
