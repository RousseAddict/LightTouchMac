// Checks the swift-subprocess stand-in against real processes, in the shapes Light Touch's nine call sites use:
// collected output and exit codes (DiskImage, FirmwareTool, LockdownTools), discarded output (DiagnosticsExport),
// the closure form with an input writer and a line sequence (HostServiceWorkers), file-descriptor output and a
// daemon the closure watches (USBMux), and a teardown sequence (PreparationJob). Runs on the Big Sur Mac
// (check/compat.sh) and CI; exits 1 on any failure.
import BigSurCompat
import Darwin
import Foundation
import Subprocess
import System

@main
struct Checks {
    static var failures = 0

    static func check(_ condition: Bool, _ what: String, line: UInt = #line) {
        if condition {
            print("ok    \(what)")
        } else {
            failures += 1
            print("FAIL  \(what) (Checks.swift:\(line))")
        }
    }

    static let sh = Executable.path(FilePath("/bin/sh"))

    static func main() async {
        do {
            try await collected()
            try await environmentAndArguments()
            try await limits()
            try await writerAndLines()
            try await fileDescriptorOutput()
            try await teardown()
            try await missingExecutable()
        } catch {
            check(false, "unexpected error: \(error)")
        }
        print(failures == 0 ? "\nAll checks passed." : "\n\(failures) checks failed.")
        exit(failures == 0 ? 0 : 1)
    }

    static func collected() async throws {
        let result = try await Subprocess.run(
            sh,
            arguments: ["-c", "echo out; echo err >&2; exit 3"],
            input: .none,
            output: .string(limit: 1 << 16),
            error: .string(limit: 1 << 16)
        )
        check(result.terminationStatus == .exited(3), "exit code 3")
        check(result.standardOutput == "out\n" && result.standardError == "err\n", "stdout and stderr collected")
        check(!result.terminationStatus.isSuccess, "isSuccess is false for exit 3")
        let signaled = try await run(sh, arguments: ["-c", "kill -TERM $$"], output: .discarded, error: .discarded)
        check(signaled.terminationStatus == .signaled(SIGTERM), "a signal is .signaled")
        let fine = try await run(.path(FilePath("/usr/bin/true")), output: .discarded)
        check(fine.terminationStatus.isSuccess, "isSuccess for exit 0")
        let status: Int32
        switch signaled.terminationStatus {
        case .exited(let code): status = code
        case .signaled(let signal): status = -signal
        }
        check(status == -SIGTERM, "an exhaustive switch over .exited and .signaled")
    }

    static func environmentAndArguments() async throws {
        setenv("BIGSUR_CHECK_REMOVED", "present", 1)
        let result = try await Subprocess.run(
            sh,
            arguments: Arguments(["-c", "echo \"$FOO-${BIGSUR_CHECK_REMOVED:-gone}-$1\"", "sh", "arg"]),
            environment: .inherit.updating(["FOO": "bar", "BIGSUR_CHECK_REMOVED": nil]),
            input: .none,
            output: .string(limit: 1024),
            error: .string(limit: 1024)
        )
        check(result.standardOutput == "bar-gone-arg\n", "environment updating sets and removes; Arguments([...])")
        let inherited = try await run(
            sh, arguments: ["-c", "echo $HOME"], output: .string(limit: 1024), error: .discarded)
        check(inherited.standardOutput == "\(NSHomeDirectory())\n", "the environment is inherited")
    }

    static func limits() async throws {
        do {
            _ = try await run(
                sh, arguments: ["-c", "head -c 5000 /dev/zero"], output: .string(limit: 1000), error: .discarded)
            check(false, "output past the limit throws")
        } catch let error as SubprocessError {
            check(error.code == .outputLimitExceeded, "output past the limit throws")
        }
        let start = CompatContinuousClock.now
        let both = try await run(
            sh,
            arguments: ["-c", "head -c 3000000 /dev/zero >&2; head -c 3000000 /dev/zero; echo done >&2"],
            input: .none,
            output: .string(limit: 1 << 23),
            error: .string(limit: 1 << 23)
        )
        check(both.standardOutput.utf8.count == 3_000_000 && both.standardError.hasSuffix("done\n"),
              "3 MB on each pipe at once doesn't deadlock")
        check(CompatContinuousClock.now - start < .seconds(10), "and it's quick")
    }

    static func writerAndLines() async throws {
        let echoed = try await Subprocess.run(
            .path(FilePath("/bin/cat")),
            input: .inputWriter,
            output: .sequence,
            error: .discarded
        ) { execution -> [String] in
            _ = try await execution.standardInputWriter.write(Data("a\nb\r\nc".utf8))
            try await execution.standardInputWriter.finish()
            var lines: [String] = []
            for try await line in execution.standardOutput.strings(bufferingPolicy: .maxLineLength(1 << 24)) {
                lines.append(line)
            }
            return lines
        }
        check(echoed.closureResult == ["a", "b", "c"], "input writer to cat, lines back (\(echoed.closureResult))")
        check(echoed.terminationStatus == .exited(0), "cat exits 0 once its input is finished")

        let separated = try await run(
            sh,
            arguments: ["-c", #"printf 'x\013y\014z\r\nw\302\205v\342\200\250u\342\200\251t\n\nlast'"#],
            input: .none,
            output: .sequence,
            error: .discarded
        ) { execution -> [String] in
            var lines: [String] = []
            for try await line in execution.standardOutput.strings() { lines.append(line) }
            return lines
        }
        check(separated.closureResult == ["x", "y", "z", "w", "v", "u", "t", "", "last"],
              "every Unicode line break splits; empty lines; a last line without one (\(separated.closureResult))")

        do {
            _ = try await run(sh, arguments: ["-c", "head -c 300 /dev/zero"], input: .none, output: .sequence,
                              error: .discarded) { execution in
                for try await _ in execution.standardOutput.strings(bufferingPolicy: .maxLineLength(100)) {}
            }
            check(false, "a line past maxLineLength throws")
        } catch let error as SubprocessError {
            check(error.code == .outputLimitExceeded, "a line past maxLineLength throws")
        }

        let big = try await run(sh, arguments: ["-c", "head -c 4000000 /dev/zero | tr '\\0' a; echo"],
                                input: .none, output: .sequence, error: .discarded) { execution -> Int in
            var total = 0
            for try await line in execution.standardOutput.strings(bufferingPolicy: .maxLineLength(16 << 20)) {
                total += line.utf8.count
            }
            return total
        }
        check(big.closureResult == 4_000_000, "a 4 MB line through the line sequence")
    }

    static func fileDescriptorOutput() async throws {
        let path = NSTemporaryDirectory() + "bigsur-subprocess-\(getpid()).log"
        let log = try FileDescriptor.open(path, .writeOnly, options: [.create, .truncate], permissions: [.ownerReadWrite])
        defer { unlink(path) }
        let result = try await run(
            sh,
            arguments: ["-c", "echo $$; echo to-err >&2"],
            input: .none,
            output: .fileDescriptor(log, closeAfterSpawningProcess: false),
            error: .fileDescriptor(log, closeAfterSpawningProcess: false)
        ) { execution in execution.processIdentifier.value }
        try log.close()
        let written = (try? String(contentsOfFile: path)) ?? ""
        check(written == "\(result.closureResult)\nto-err\n", "both outputs to one file descriptor; processIdentifier")
    }

    static func teardown() async throws {
        let killed = Task {
            try await run(.path(FilePath("/bin/sleep")), arguments: ["30"], output: .discarded, error: .discarded)
        }
        try await Task.compatSleep(for: .milliseconds(200))
        let cancelledAt = CompatContinuousClock.now
        killed.cancel()
        let killedResult = try await killed.value
        check(killedResult.terminationStatus == .signaled(SIGKILL), "cancelling tears down with SIGKILL by default")
        check(CompatContinuousClock.now - cancelledAt < .seconds(2), "and run returns promptly")

        let options: PlatformOptions = {
            var options = PlatformOptions()
            options.teardownSequence = [.send(signal: .terminate, allowedDurationToNextStep: .seconds(5))]
            return options
        }()
        let graceful = Task {
            try await Subprocess.run(
                sh,
                arguments: ["-c", "trap 'exit 7' TERM; sleep 30 & wait"],
                platformOptions: options,
                input: .none,
                output: .sequence,
                error: .discarded
            ) { execution in
                for try await _ in execution.standardOutput.strings() {}
            }
        }
        try await Task.compatSleep(for: .milliseconds(300))
        graceful.cancel()
        let gracefulStatus = try? await graceful.value.terminationStatus
        check(gracefulStatus == .exited(7), "a teardown sequence sends SIGTERM first (\(String(describing: gracefulStatus)))")

        struct Stop: Swift.Error {}
        var pid: pid_t = 0
        let started = CompatContinuousClock.now
        do {
            _ = try await run(.path(FilePath("/bin/sleep")), arguments: ["30"], input: .none, output: .discarded,
                              error: .discarded) { execution in
                pid = execution.processIdentifier.value
                throw Stop()
            }
            check(false, "a throwing closure's error is rethrown")
        } catch is Stop {
            check(kill(pid, 0) != 0 && CompatContinuousClock.now - started < .seconds(2),
                  "a throwing closure's error is rethrown, the child torn down and reaped")
        }

        let watched = try await run(sh, arguments: ["-c", "sleep 0.3"], input: .none, output: .discarded,
                                    error: .discarded) { execution -> Bool in
            let pid = execution.processIdentifier.value
            for _ in 0..<50 {
                try await Task.compatSleep(for: .milliseconds(100))
                if kill(pid, 0) != 0 { return true }
            }
            return false
        }
        check(watched.closureResult, "a closure watching the pid sees the child exit on its own (USBMux)")
    }

    static func missingExecutable() async throws {
        do {
            _ = try await run(.path(FilePath("/nonexistent/tool")), output: .discarded)
            check(false, "a missing executable throws")
        } catch let error as SubprocessError {
            check(error.code == .spawnFailed, "a missing executable throws (\(error))")
        }
    }
}
