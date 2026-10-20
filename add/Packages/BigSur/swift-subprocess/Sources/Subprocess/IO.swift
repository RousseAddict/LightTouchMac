// Where a subprocess's standard input comes from and its output goes: swift-subprocess 1.0.0's protocols and the
// kinds Light Touch uses (.none and .inputWriter; .discarded, .string(limit:), .sequence and .fileDescriptor).
import Foundation
import System

/// How the subprocess's standard input is provided.
public protocol InputProtocol: Sendable {
    var _inputKind: _InputKind { get }
}

public enum _InputKind: Sendable {
    case none
    case writer
}

/// No input: the subprocess reads /dev/null.
public struct NoInput: InputProtocol {
    public var _inputKind: _InputKind { .none }

    public init() {}
}

/// Input written by the closure through `execution.standardInputWriter`.
public struct CustomWriteInput: InputProtocol {
    public var _inputKind: _InputKind { .writer }

    public init() {}
}

extension InputProtocol where Self == NoInput {
    public static var none: Self { NoInput() }
}

extension InputProtocol where Self == CustomWriteInput {
    public static var inputWriter: Self { CustomWriteInput() }
}

/// What happens to the subprocess's standard output (or error), and what the result carries of it.
public protocol OutputProtocol: Sendable {
    associatedtype OutputType: Sendable
    var _outputKind: _OutputKind { get }
    func _output(from data: Data) throws -> OutputType
}

/// An output the subprocess's standard error can also take.
public protocol ErrorOutputProtocol: OutputProtocol {}

public enum _OutputKind: Sendable {
    case discarded
    case collected(limit: Int)
    case sequence
    case fileDescriptor(FileDescriptor, closeAfterSpawning: Bool)
}

/// Sent to /dev/null.
public struct DiscardedOutput: OutputProtocol, ErrorOutputProtocol {
    public typealias OutputType = Void
    public var _outputKind: _OutputKind { .discarded }
    public func _output(from data: Data) throws {}

    public init() {}
}

/// Collected as UTF-8 text, up to `limit` bytes; more is an error.
public struct StringOutput: OutputProtocol, ErrorOutputProtocol {
    public typealias OutputType = String
    public let maxSize: Int
    public var _outputKind: _OutputKind { .collected(limit: maxSize) }

    public func _output(from data: Data) throws -> String {
        String(decoding: data, as: UTF8.self)
    }
}

/// Read by the closure through `execution.standardOutput` (or `standardError`).
public struct SequenceOutput: OutputProtocol, ErrorOutputProtocol {
    public typealias OutputType = Void
    public var _outputKind: _OutputKind { .sequence }
    public func _output(from data: Data) throws {}

    public init() {}
}

/// Written to this file descriptor, closed in this process after the spawn when asked.
public struct FileDescriptorOutput: OutputProtocol, ErrorOutputProtocol {
    public typealias OutputType = Void
    let descriptor: FileDescriptor
    let closeAfterSpawningProcess: Bool
    public var _outputKind: _OutputKind { .fileDescriptor(descriptor, closeAfterSpawning: closeAfterSpawningProcess) }
    public func _output(from data: Data) throws {}
}

extension OutputProtocol where Self == DiscardedOutput {
    public static var discarded: Self { DiscardedOutput() }
}

extension OutputProtocol where Self == StringOutput {
    public static func string(limit: Int) -> Self { StringOutput(maxSize: limit) }
}

extension OutputProtocol where Self == SequenceOutput {
    public static var sequence: Self { SequenceOutput() }
}

extension OutputProtocol where Self == FileDescriptorOutput {
    public static func fileDescriptor(_ fd: FileDescriptor, closeAfterSpawningProcess: Bool) -> Self {
        FileDescriptorOutput(descriptor: fd, closeAfterSpawningProcess: closeAfterSpawningProcess)
    }
}
