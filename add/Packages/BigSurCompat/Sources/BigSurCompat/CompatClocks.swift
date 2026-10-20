// macOS 13's ContinuousClock and SuspendingClock for macOS 11, on the same Darwin clocks the standard library reads:
// CLOCK_MONOTONIC_RAW keeps counting while the Mac sleeps, CLOCK_UPTIME_RAW doesn't.
import Darwin

/// A point in time on one of the compat clocks, in nanoseconds since that clock's origin.
public struct CompatInstant<Clock: CompatClockSource>: Sendable, Hashable, Comparable {
    public var nanoseconds: Int64

    public init(nanoseconds: Int64) {
        self.nanoseconds = nanoseconds
    }

    public static var now: CompatInstant { CompatInstant(nanoseconds: Clock.nanosecondsNow()) }

    public func advanced(by duration: CompatDuration) -> CompatInstant {
        CompatInstant(nanoseconds: nanoseconds + duration.nanoseconds)
    }

    public func duration(to other: CompatInstant) -> CompatDuration {
        CompatDuration(nanoseconds: other.nanoseconds - nanoseconds)
    }

    public static func < (lhs: CompatInstant, rhs: CompatInstant) -> Bool { lhs.nanoseconds < rhs.nanoseconds }

    public static func + (lhs: CompatInstant, rhs: CompatDuration) -> CompatInstant { lhs.advanced(by: rhs) }

    public static func - (lhs: CompatInstant, rhs: CompatDuration) -> CompatInstant { lhs.advanced(by: -rhs) }

    public static func - (lhs: CompatInstant, rhs: CompatInstant) -> CompatDuration { rhs.duration(to: lhs) }

    public static func += (lhs: inout CompatInstant, rhs: CompatDuration) { lhs = lhs + rhs }

    public static func -= (lhs: inout CompatInstant, rhs: CompatDuration) { lhs = lhs - rhs }
}

/// The Darwin clock a compat clock reads.
public protocol CompatClockSource: Sendable {
    static func nanosecondsNow() -> Int64
}

/// Stands in for `ContinuousClock`: keeps counting while the Mac sleeps.
public struct CompatContinuousClock: CompatClockSource, Sendable {
    public typealias Instant = CompatInstant<CompatContinuousClock>

    public init() {}

    public static func nanosecondsNow() -> Int64 { Int64(clock_gettime_nsec_np(CLOCK_MONOTONIC_RAW)) }

    public static var now: Instant { .now }

    public var now: Instant { .now }

    public func sleep(until deadline: Instant, tolerance: CompatDuration? = nil) async throws {
        try await Task.compatSleep(for: Instant.now.duration(to: deadline))
    }
}

/// Stands in for `SuspendingClock`: stops while the Mac sleeps.
public struct CompatSuspendingClock: CompatClockSource, Sendable {
    public typealias Instant = CompatInstant<CompatSuspendingClock>

    public init() {}

    public static func nanosecondsNow() -> Int64 { Int64(clock_gettime_nsec_np(CLOCK_UPTIME_RAW)) }

    public static var now: Instant { .now }

    public var now: Instant { .now }

    public func sleep(until deadline: Instant, tolerance: CompatDuration? = nil) async throws {
        try await Task.compatSleep(for: Instant.now.duration(to: deadline), clock: .suspending)
    }
}

/// Which clock `Task.compatSleep` measures with, as `Task.sleep(for:clock:)`'s `.continuous` and `.suspending`.
public enum CompatSleepClock: Sendable {
    case continuous
    case suspending
}

extension Task where Success == Never, Failure == Never {
    /// Stands in for `Task.sleep(for:tolerance:clock:)`: suspends for `duration` (none when it's zero or negative),
    /// and throws `CancellationError` if the task is cancelled first.
    public static func compatSleep(
        for duration: CompatDuration,
        tolerance: CompatDuration? = nil,
        clock: CompatSleepClock = .continuous
    ) async throws {
        guard duration.nanoseconds > 0 else {
            try Task.checkCancellation()
            return
        }
        try await Task.sleep(nanoseconds: UInt64(duration.nanoseconds))
    }
}
