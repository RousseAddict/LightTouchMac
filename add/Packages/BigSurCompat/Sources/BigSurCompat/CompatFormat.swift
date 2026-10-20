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
