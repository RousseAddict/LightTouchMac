// macOS 12's FormatStyle forms Light Touch uses, for macOS 11, on the formatters that produce the same text
// (compat-checks compares them on CI, where both exist). The ISO 8601 formatters are made once; formatting with them
// from several threads is safe.
import Foundation

public enum CompatFormat {
    private static let internetDateTime = ISO8601DateFormatter()
    private static let fullDate: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter
    }()

    /// `date.ISO8601Format()`: "2026-10-20T15:04:05Z".
    public static func iso8601(_ date: Date) -> String { internetDateTime.string(from: date) }

    /// `date.formatted(.iso8601.year().month().day())`: "2026-10-20", in UTC.
    public static func iso8601Day(_ date: Date) -> String { fullDate.string(from: date) }

    /// `try? Date(string, strategy: .iso8601)`.
    public static func parseISO8601(_ string: String) -> Date? { internetDateTime.date(from: string) }

    /// `try? Date(string, strategy: .iso8601.year().month().day())`: "2011-06-07" as that day's start in UTC.
    public static func parseISO8601Day(_ string: String) -> Date? { fullDate.date(from: string) }

    /// `count.formatted(.byteCount(style: .file))`: "12.3 GB".
    public static func fileBytes<T: BinaryInteger>(_ count: T) -> String {
        ByteCountFormatter.string(fromByteCount: Int64(count), countStyle: .file)
    }

    /// `value.formatted()` for an integer: "1,048,576" in the current locale.
    public static func decimal<T: BinaryInteger>(_ value: T) -> String {
        NumberFormatter.localizedString(from: NSNumber(value: Int64(value)), number: .decimal)
    }

    /// `date.formatted(Date.FormatStyle(date: .long, time: .omitted, timeZone:))`: "June 7, 2011".
    public static func longDate(_ date: Date, timeZone: TimeZone = .current) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.timeZone = timeZone
        return formatter.string(from: date)
    }
}

extension BinaryInteger {
    /// `formatted(.byteCount(style: .file))`.
    public func compatFileBytes() -> String { CompatFormat.fileBytes(self) }
}

/// The date and time styles of `Date.formatted(date:time:)`.
public enum CompatDateStyle: Sendable {
    case omitted, numeric, abbreviated, long, complete

    var style: DateFormatter.Style {
        switch self {
        case .omitted: return .none
        case .numeric: return .short
        case .abbreviated: return .medium
        case .long: return .long
        case .complete: return .full
        }
    }
}

public enum CompatTimeStyle: Sendable {
    case omitted, shortened, standard, complete

    var style: DateFormatter.Style {
        switch self {
        case .omitted: return .none
        case .shortened: return .short
        case .standard: return .medium
        case .complete: return .full
        }
    }
}

extension Date {
    /// `formatted(date:time:)`, in the current locale and time zone.
    public func compatFormatted(date: CompatDateStyle, time: CompatTimeStyle) -> String {
        DateFormatter.localizedString(from: self, dateStyle: date.style, timeStyle: time.style)
    }
}
