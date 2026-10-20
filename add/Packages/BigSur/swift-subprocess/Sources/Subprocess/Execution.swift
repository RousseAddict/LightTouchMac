// What the closure passed to run(...) works with, and what run(...) returns: swift-subprocess 1.0.0's Execution,
// ExecutionResult, StandardInputWriter and SubprocessOutputSequence, with the members Light Touch uses.
import Darwin
import Foundation

/// A running subprocess, as the closure passed to `run` sees it. Its standard input writer exists when the input is
/// `.inputWriter`, its output sequences when the outputs are `.sequence`.
public struct Execution<Input: InputProtocol, Output: OutputProtocol, Error: OutputProtocol>: Sendable {
    public let processIdentifier: ProcessIdentifier
    let writer: StandardInputWriter?
    let output: SubprocessOutputSequence?
    let error: SubprocessOutputSequence?
}

extension Execution where Input == CustomWriteInput {
    public var standardInputWriter: StandardInputWriter { writer! }
}

extension Execution where Output == SequenceOutput {
    public var standardOutput: SubprocessOutputSequence { output! }
}

extension Execution where Error == SequenceOutput {
    public var standardError: SubprocessOutputSequence { error! }
}

/// How a subprocess ended, what the closure returned, and the output collected with `.string(limit:)`.
public struct ExecutionResult<Result, Output: OutputProtocol, Error: OutputProtocol> {
    public let processIdentifier: ProcessIdentifier
    public let terminationStatus: TerminationStatus
    public let standardOutput: Output.OutputType
    public let standardError: Error.OutputType
    public let closureResult: Result
}

extension ExecutionResult: Sendable where Result: Sendable {}

/// Writes the subprocess's standard input. Writes happen in order on a queue of their own, so a full pipe never
/// blocks a Swift concurrency thread; a closed pipe is an error, not a SIGPIPE.
public final class StandardInputWriter: @unchecked Sendable {
    private let queue = DispatchQueue(label: "Subprocess.StandardInputWriter")
    private var descriptor: CInt?  // used on `queue` only

    init(descriptor: CInt) {
        _ = fcntl(descriptor, F_SETNOSIGPIPE, 1)
        self.descriptor = descriptor
    }

    deinit {
        if let descriptor = descriptor { close(descriptor) }
    }

    @discardableResult
    public func write(_ data: Data) async throws -> Int {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Int, Swift.Error>) in
            queue.async {
                guard let descriptor = self.descriptor else {
                    return continuation.resume(throwing: SubprocessError.errno(.writeFailed, "write", EBADF))
                }
                let failure: CInt? = data.withUnsafeBytes { buffer -> CInt? in
                    var offset = 0
                    while offset < buffer.count {
                        let written = Darwin.write(descriptor, buffer.baseAddress! + offset, buffer.count - offset)
                        if written < 0 {
                            if errno == EINTR { continue }
                            return errno
                        }
                        offset += written
                    }
                    return nil
                }
                if let failure = failure {
                    continuation.resume(throwing: SubprocessError.errno(.writeFailed, "write", failure))
                } else {
                    continuation.resume(returning: data.count)
                }
            }
        }
    }

    @discardableResult
    public func write(_ bytes: [UInt8]) async throws -> Int { try await write(Data(bytes)) }

    @discardableResult
    public func write(_ string: String) async throws -> Int { try await write(Data(string.utf8)) }

    /// Closes the subprocess's standard input, which it reads as the end of its input.
    public func finish() async throws {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            queue.async {
                if let descriptor = self.descriptor { close(descriptor) }
                self.descriptor = nil
                continuation.resume()
            }
        }
    }

    /// For run(...)'s cleanup, which can't await.
    func closeWhenDone() {
        queue.async {
            if let descriptor = self.descriptor { close(descriptor) }
            self.descriptor = nil
        }
    }
}

/// The subprocess's standard output (or error) as it arrives, in chunks; `strings()` splits it into lines.
public struct SubprocessOutputSequence: AsyncSequence, @unchecked Sendable {
    public typealias Element = Data

    let stream: AsyncThrowingStream<Data, Swift.Error>

    public struct AsyncIterator: AsyncIteratorProtocol {
        var base: AsyncThrowingStream<Data, Swift.Error>.AsyncIterator

        public mutating func next() async throws -> Data? { try await base.next() }
    }

    public func makeAsyncIterator() -> AsyncIterator { AsyncIterator(base: stream.makeAsyncIterator()) }

    /// The output as UTF-8 lines, without their line breaks, as 1.0.0's: LF, VT, FF, CR, CR LF, NEL, LS and PS end
    /// a line; an empty line is ""; the last line needs no break. A line longer than the policy allows throws.
    public func strings(
        bufferingPolicy: StringSequence.BufferingPolicy = .maxLineLength(128 * 1024)
    ) -> StringSequence {
        StringSequence(chunks: self, policy: bufferingPolicy)
    }

    public struct StringSequence: AsyncSequence, @unchecked Sendable {
        public typealias Element = String

        public enum BufferingPolicy: Sendable {
            case unbounded
            case maxLineLength(Int)
        }

        let chunks: SubprocessOutputSequence
        let policy: BufferingPolicy

        public func makeAsyncIterator() -> AsyncIterator {
            AsyncIterator(chunks: chunks.makeAsyncIterator(), policy: policy)
        }

        public struct AsyncIterator: AsyncIteratorProtocol {
            var chunks: SubprocessOutputSequence.AsyncIterator
            let policy: BufferingPolicy
            var pending: [UInt8] = []
            var index = 0
            var line: [UInt8] = []
            var ended = false

            init(chunks: SubprocessOutputSequence.AsyncIterator, policy: BufferingPolicy) {
                self.chunks = chunks
                self.policy = policy
            }

            /// Appends more output to `pending`, dropping what's been consumed; false at the end of the output.
            mutating func load() async throws -> Bool {
                if ended { return false }
                guard let chunk = try await chunks.next() else {
                    ended = true
                    return false
                }
                pending.removeFirst(index)
                index = 0
                pending.append(contentsOf: chunk)
                return true
            }

            /// The byte `offset` places past `index`, reading more output when needed; nil at the end of it.
            mutating func peek(_ offset: Int) async throws -> UInt8? {
                while index + offset >= pending.count {
                    guard try await load() else { return nil }
                }
                return pending[index + offset]
            }

            mutating func emit() -> String {
                defer { line.removeAll(keepingCapacity: true) }
                return String(decoding: line, as: UTF8.self)
            }

            mutating func append(_ byte: UInt8) throws {
                line.append(byte)
                index += 1
                if case .maxLineLength(let limit) = policy, line.count > limit {
                    throw SubprocessError.outputLimitExceeded(limit: limit)
                }
            }

            public mutating func next() async throws -> String? {
                while true {
                    // What's buffered is scanned without awaiting; only a CR, or a byte that may start NEL, LS or
                    // PS, needs to look further.
                    while index < pending.count {
                        let byte = pending[index]
                        if byte == 0x0A || byte == 0x0B || byte == 0x0C {
                            index += 1
                            return emit()
                        }
                        if byte == 0x0D || byte == 0xC2 || byte == 0xE2 { break }
                        try append(byte)
                    }
                    guard index < pending.count else {
                        guard try await load() else { return line.isEmpty ? nil : emit() }
                        continue
                    }
                    switch pending[index] {
                    case 0x0D:
                        index += try await peek(1) == 0x0A ? 2 : 1
                        return emit()
                    case 0xC2:
                        if try await peek(1) == 0x85 {
                            index += 2
                            return emit()
                        }
                    case 0xE2:
                        if try await peek(1) == 0x80, let third = try await peek(2), third == 0xA8 || third == 0xA9 {
                            index += 3
                            return emit()
                        }
                    default:
                        break
                    }
                    try append(pending[index])
                }
            }
        }
    }
}
