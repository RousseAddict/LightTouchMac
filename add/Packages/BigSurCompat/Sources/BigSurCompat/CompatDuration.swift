// macOS 13's Duration for macOS 11, with the members Light Touch uses. It counts nanoseconds; the standard library's
// counts attoseconds, a precision nothing here needs. The static constructors live in the type itself rather than an
// extension so MemberImportVisibility finds them wherever the type is visible.
import Foundation

/// A signed span of time, standing in for the standard library's `Duration`.
public struct CompatDuration: Sendable, Hashable, Comparable, CustomStringConvertible {
    /// The span in nanoseconds.
    public var nanoseconds: Int64

    public init(nanoseconds: Int64) {
        self.nanoseconds = nanoseconds
    }

    public static var zero: CompatDuration { CompatDuration(nanoseconds: 0) }

    public static func seconds<T: BinaryInteger>(_ seconds: T) -> CompatDuration {
        CompatDuration(nanoseconds: Int64(seconds) * 1_000_000_000)
    }

    public static func seconds(_ seconds: Double) -> CompatDuration {
        CompatDuration(nanoseconds: Int64((seconds * 1e9).rounded()))
    }

    public static func milliseconds<T: BinaryInteger>(_ milliseconds: T) -> CompatDuration {
        CompatDuration(nanoseconds: Int64(milliseconds) * 1_000_000)
    }

    public static func milliseconds(_ milliseconds: Double) -> CompatDuration {
        CompatDuration(nanoseconds: Int64((milliseconds * 1e6).rounded()))
    }

    public static func microseconds<T: BinaryInteger>(_ microseconds: T) -> CompatDuration {
        CompatDuration(nanoseconds: Int64(microseconds) * 1_000)
    }

    public static func microseconds(_ microseconds: Double) -> CompatDuration {
        CompatDuration(nanoseconds: Int64((microseconds * 1e3).rounded()))
    }

    public static func nanoseconds<T: BinaryInteger>(_ nanoseconds: T) -> CompatDuration {
        CompatDuration(nanoseconds: Int64(nanoseconds))
    }

    /// The span in seconds, as Foundation's `TimeInterval`.
    public var timeInterval: TimeInterval { Double(nanoseconds) / 1e9 }

    /// Whole seconds and the remainder in attoseconds, as `Duration.components` reports them.
    public var components: (seconds: Int64, attoseconds: Int64) {
        let (seconds, remainder) = nanoseconds.quotientAndRemainder(dividingBy: 1_000_000_000)
        return (seconds, remainder * 1_000_000_000)
    }

    /// The standard library's form: "1.5 seconds".
    public var description: String { "\(timeInterval) seconds" }

    public static func < (lhs: CompatDuration, rhs: CompatDuration) -> Bool { lhs.nanoseconds < rhs.nanoseconds }

    public static func + (lhs: CompatDuration, rhs: CompatDuration) -> CompatDuration {
        CompatDuration(nanoseconds: lhs.nanoseconds + rhs.nanoseconds)
    }

    public static func - (lhs: CompatDuration, rhs: CompatDuration) -> CompatDuration {
        CompatDuration(nanoseconds: lhs.nanoseconds - rhs.nanoseconds)
    }

    public static func += (lhs: inout CompatDuration, rhs: CompatDuration) { lhs = lhs + rhs }

    public static func -= (lhs: inout CompatDuration, rhs: CompatDuration) { lhs = lhs - rhs }

    public static prefix func - (duration: CompatDuration) -> CompatDuration {
        CompatDuration(nanoseconds: -duration.nanoseconds)
    }

    public static func * <T: BinaryInteger>(lhs: CompatDuration, rhs: T) -> CompatDuration {
        CompatDuration(nanoseconds: lhs.nanoseconds * Int64(rhs))
    }

    public static func * (lhs: CompatDuration, rhs: Double) -> CompatDuration {
        CompatDuration(nanoseconds: Int64((Double(lhs.nanoseconds) * rhs).rounded()))
    }

    public static func / <T: BinaryInteger>(lhs: CompatDuration, rhs: T) -> CompatDuration {
        CompatDuration(nanoseconds: lhs.nanoseconds / Int64(rhs))
    }

    public static func / (lhs: CompatDuration, rhs: Double) -> CompatDuration {
        CompatDuration(nanoseconds: Int64((Double(lhs.nanoseconds) / rhs).rounded()))
    }

    /// How many times `rhs` fits in `lhs`.
    public static func / (lhs: CompatDuration, rhs: CompatDuration) -> Double {
        Double(lhs.nanoseconds) / Double(rhs.nanoseconds)
    }
}
