// run(...), with swift-subprocess 1.0.0's signatures and semantics for what Light Touch uses:
// - The closure form returns once the closure has returned and the child has exited (it isn't stopped).
// - If the closure throws, or the calling task is cancelled, the child is torn down (the platform options'
//   sequence, then SIGKILL) and run waits for it before returning or rethrowing.
// - The collected form is the closure form with an empty closure.
// - .string(limit:) outputs are read to the end on threads of their own (so a chatty stderr never blocks the child
//   while stdout is read), and more than the limit is an error.
// - A non-zero exit is a result: see ExecutionResult.terminationStatus.
import BigSurCompat
import Foundation
import System

/// Runs `executable` and returns how it ended and the output collected with `.string(limit:)`. 1.0.0 gives
/// `input` and `error` default values (.none, .discarded); generic defaults need Swift 5.7, so the overloads below
/// spell those out, which reads the same at the call site.
public func run<Input: InputProtocol, Output: OutputProtocol, Error: ErrorOutputProtocol>(
    _ executable: Executable,
    arguments: Arguments = [],
    environment: Environment = .inherit,
    workingDirectory: FilePath? = nil,
    platformOptions: PlatformOptions = PlatformOptions(),
    input: Input,
    output: Output,
    error: Error
) async throws -> ExecutionResult<Void, Output, Error> {
    try await run(
        executable,
        arguments: arguments,
        environment: environment,
        workingDirectory: workingDirectory,
        platformOptions: platformOptions,
        input: input,
        output: output,
        error: error
    ) { _ in }
}

/// `run` with no input.
public func run<Output: OutputProtocol, Error: ErrorOutputProtocol>(
    _ executable: Executable,
    arguments: Arguments = [],
    environment: Environment = .inherit,
    workingDirectory: FilePath? = nil,
    platformOptions: PlatformOptions = PlatformOptions(),
    output: Output,
    error: Error
) async throws -> ExecutionResult<Void, Output, Error> {
    try await run(
        executable, arguments: arguments, environment: environment, workingDirectory: workingDirectory,
        platformOptions: platformOptions, input: NoInput(), output: output, error: error)
}

/// `run` with standard error discarded.
public func run<Input: InputProtocol, Output: OutputProtocol>(
    _ executable: Executable,
    arguments: Arguments = [],
    environment: Environment = .inherit,
    workingDirectory: FilePath? = nil,
    platformOptions: PlatformOptions = PlatformOptions(),
    input: Input,
    output: Output
) async throws -> ExecutionResult<Void, Output, DiscardedOutput> {
    try await run(
        executable, arguments: arguments, environment: environment, workingDirectory: workingDirectory,
        platformOptions: platformOptions, input: input, output: output, error: DiscardedOutput())
}

/// `run` with no input and standard error discarded.
public func run<Output: OutputProtocol>(
    _ executable: Executable,
    arguments: Arguments = [],
    environment: Environment = .inherit,
    workingDirectory: FilePath? = nil,
    platformOptions: PlatformOptions = PlatformOptions(),
    output: Output
) async throws -> ExecutionResult<Void, Output, DiscardedOutput> {
    try await run(
        executable, arguments: arguments, environment: environment, workingDirectory: workingDirectory,
        platformOptions: platformOptions, input: NoInput(), output: output, error: DiscardedOutput())
}

/// Runs `executable`, hands the running child to `body`, and returns how it ended and what `body` returned.
public func run<Result, Input: InputProtocol, Output: OutputProtocol, Error: ErrorOutputProtocol>(
    _ executable: Executable,
    arguments: Arguments = [],
    environment: Environment = .inherit,
    workingDirectory: FilePath? = nil,
    platformOptions: PlatformOptions = PlatformOptions(),
    input: Input,
    output: Output,
    error: Error,
    body: (Execution<Input, Output, Error>) async throws -> Result
) async throws -> ExecutionResult<Result, Output, Error> {
    try Task.checkCancellation()
    let child = try spawn(
        executable,
        arguments: arguments,
        environment: environment,
        workingDirectory: workingDirectory,
        input: input._inputKind,
        output: output._outputKind,
        error: error._outputKind
    )
    let waiter = ProcessWaiter(pid: child.pid)
    let teardown = platformOptions.teardownSequence
    let writer = child.stdinWrite.map { StandardInputWriter(descriptor: $0) }
    let outputReader = child.stdoutRead.map { PipeReader(descriptor: $0, waiter: waiter) }
    let errorReader = child.stderrRead.map { PipeReader(descriptor: $0, waiter: waiter) }

    // Collected outputs are read alongside the closure, whatever it does.
    let collectedOutput = collector(for: output._outputKind, reader: outputReader)
    let collectedError = collector(for: error._outputKind, reader: errorReader)
    let execution = Execution<Input, Output, Error>(
        processIdentifier: ProcessIdentifier(value: child.pid),
        writer: writer,
        output: sequence(for: output._outputKind, reader: outputReader),
        error: sequence(for: error._outputKind, reader: errorReader)
    )

    let outcome: Swift.Result<Result, Swift.Error>
    do {
        let value = try await whileTornDownOnCancel(waiter, teardown) { try await body(execution) }
        outcome = .success(value)
    } catch let failure {
        waiter.tearDown(teardown)
        outcome = .failure(failure)
    }
    writer?.closeWhenDone()
    let status = try await whileTornDownOnCancel(waiter, teardown) { await waiter.wait() }
    let standardOutput = try await collectedOutput?.value
    let standardError = try await collectedError?.value
    switch outcome {
    case .failure(let failure):
        throw failure
    case .success(let value):
        return ExecutionResult(
            processIdentifier: ProcessIdentifier(value: child.pid),
            terminationStatus: status,
            standardOutput: try output._output(from: standardOutput ?? Data()),
            standardError: try error._output(from: standardError ?? Data()),
            closureResult: value
        )
    }
}

private func collector(for kind: _OutputKind, reader: PipeReader?) -> Task<Data, Swift.Error>? {
    guard case .collected(let limit) = kind, let reader = reader else { return nil }
    return Task { try await reader.collect(limit: limit) }
}

private func sequence(for kind: _OutputKind, reader: PipeReader?) -> SubprocessOutputSequence? {
    guard case .sequence = kind, let reader = reader else { return nil }
    return SubprocessOutputSequence(stream: reader.stream)
}

/// Runs `operation`, tearing the child down if the calling task is cancelled meanwhile.
private func whileTornDownOnCancel<T>(
    _ waiter: ProcessWaiter,
    _ teardown: [TeardownStep],
    _ operation: () async throws -> T
) async throws -> T {
    #if compiler(>=5.7)
        return try await withTaskCancellationHandler(operation: operation) { waiter.tearDown(teardown) }
    #else
        return try await withTaskCancellationHandler(handler: { waiter.tearDown(teardown) }, operation: operation)
    #endif
}
