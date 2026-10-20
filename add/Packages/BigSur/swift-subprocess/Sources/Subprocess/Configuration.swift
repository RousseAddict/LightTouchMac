// What a subprocess is run with, and how it ended: swift-subprocess 1.0.0's types, with the members Light Touch uses.
import BigSurCompat
import Darwin
import Foundation
import System

/// The program to run.
public struct Executable: Sendable, Hashable {
    enum Storage: Sendable, Hashable {
        case path(String)
        case name(String)
    }

    let storage: Storage

    /// The program at this path.
    public static func path(_ path: FilePath) -> Executable {
        Executable(storage: .path(path.withCString { String(cString: $0) }))
    }

    /// The program named this, found on PATH.
    public static func name(_ name: String) -> Executable {
        Executable(storage: .name(name))
    }
}

/// The program's arguments, not including its own name.
public struct Arguments: Sendable, Hashable, ExpressibleByArrayLiteral {
    public let storage: [String]

    public init(_ array: [String]) {
        storage = array
    }

    public init(arrayLiteral elements: String...) {
        storage = elements
    }
}

/// The program's environment.
public struct Environment: Sendable, Hashable {
    let base: [String: String]?  // nil: this process's
    let updates: [String: String?]

    /// This process's environment.
    public static var inherit: Environment { Environment(base: nil, updates: [:]) }

    /// Exactly these variables.
    public static func custom(_ values: [String: String]) -> Environment {
        Environment(base: values, updates: [:])
    }

    /// This environment with `values` set, and removed where the value is nil.
    public func updating(_ values: [String: String?]) -> Environment {
        Environment(base: base, updates: updates.merging(values) { _, new in new })
    }

    var resolved: [String: String] {
        var variables = base ?? ProcessInfo.processInfo.environment
        for (key, value) in updates {
            variables[key] = value
        }
        return variables
    }
}

/// How the subprocess ended.
public enum TerminationStatus: Sendable, Hashable {
    public typealias Code = CInt

    /// It exited with this code.
    case exited(Code)
    /// A signal ended it.
    case signaled(Code)

    public var isSuccess: Bool { self == .exited(0) }

    init(waitStatus status: CInt) {
        let signal = status & 0x7F
        self = signal == 0 ? .exited((status >> 8) & 0xFF) : .signaled(signal)
    }
}

/// The subprocess's process ID.
public struct ProcessIdentifier: Sendable, Hashable {
    public let value: pid_t

    public init(value: pid_t) {
        self.value = value
    }
}

/// A signal sent to the subprocess.
public struct Signal: Sendable, Hashable {
    public let rawValue: CInt

    public init(rawValue: CInt) {
        self.rawValue = rawValue
    }

    public static var interrupt: Signal { Signal(rawValue: SIGINT) }
    public static var terminate: Signal { Signal(rawValue: SIGTERM) }
    public static var kill: Signal { Signal(rawValue: SIGKILL) }
    public static var hangup: Signal { Signal(rawValue: SIGHUP) }
    public static var quit: Signal { Signal(rawValue: SIGQUIT) }
}

/// One step of tearing a subprocess down: a signal, and how long it gets to exit before the next step. The sequence
/// always ends with `.kill`.
public struct TeardownStep: Sendable, Hashable {
    let signal: Signal
    let allowed: CompatDuration

    public static func send(signal: Signal, allowedDurationToNextStep: CompatDuration) -> TeardownStep {
        TeardownStep(signal: signal, allowed: allowedDurationToNextStep)
    }

    /// SIGTERM, then the time it gets.
    public static func gracefulShutDown(allowedDurationToNextStep: CompatDuration) -> TeardownStep {
        send(signal: .terminate, allowedDurationToNextStep: allowedDurationToNextStep)
    }
}

/// Darwin options: the teardown run when the calling task is cancelled or the closure throws.
public struct PlatformOptions: Sendable, Hashable {
    public var teardownSequence: [TeardownStep] = []

    public init() {}
}

/// What went wrong running a subprocess. A non-zero exit is a result, not an error.
public struct SubprocessError: Swift.Error, Sendable, Hashable, CustomStringConvertible {
    public enum Code: Sendable, Hashable {
        case spawnFailed
        case outputLimitExceeded
        case writeFailed
        case readFailed
    }

    public let code: Code
    public let underlyingErrno: CInt?
    public let detail: String

    public var description: String { detail }

    static func errno(_ code: Code, _ what: String, _ value: CInt = Darwin.errno) -> SubprocessError {
        SubprocessError(code: code, underlyingErrno: value, detail: "\(what): \(String(cString: strerror(value)))")
    }

    static func outputLimitExceeded(limit: Int) -> SubprocessError {
        SubprocessError(code: .outputLimitExceeded, underlyingErrno: nil, detail: "Output exceeded \(limit) bytes")
    }
}

extension SubprocessError: LocalizedError {
    public var errorDescription: String? { detail }
}
