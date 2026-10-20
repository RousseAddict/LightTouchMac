// macOS 13's Regex, as far as Light Touch's patterns use it, for macOS 11: NSRegularExpression (ICU) behind the
// standard library's verbs (firstMatch(of:), wholeMatch(of:), matches(of:), contains(_:)) with a compat prefix.
// The patterns are ASCII, where ICU and Swift's regex engine agree (case-insensitive and multi-line flags, \w \s \d,
// lazy quantifiers, \x escapes). A match's groups read as match[1] where a Regex output reads match.1.
import Foundation

public struct CompatRegex: @unchecked Sendable {
    let expression: NSRegularExpression

    /// A regular expression from a literal pattern; an invalid one is a programming error.
    public init(_ pattern: String) {
        do {
            expression = try NSRegularExpression(pattern: pattern)
        } catch {
            preconditionFailure("CompatRegex: invalid pattern \(pattern): \(error)")
        }
    }
}

/// One match: the whole match and its capture groups, as Substrings of the text searched.
public struct CompatRegexMatch {
    private let groups: [Substring]

    init(_ result: NSTextCheckingResult, in text: String) {
        groups = (0..<result.numberOfRanges).map { group in
            Range(result.range(at: group), in: text).map { text[$0] } ?? ""
        }
    }

    /// The whole match, as a Regex match's `output`.
    public var output: Substring { groups[0] }

    /// Capture group `group` (0 is the whole match); empty when that group took no part in the match.
    public subscript(_ group: Int) -> Substring { group < groups.count ? groups[group] : "" }
}

extension StringProtocol {
    public func compatFirstMatch(of regex: CompatRegex) -> CompatRegexMatch? {
        let text = String(self)
        let whole = NSRange(text.startIndex..., in: text)
        return regex.expression.firstMatch(in: text, range: whole).map { CompatRegexMatch($0, in: text) }
    }

    /// The match that spans the whole string, if any: the pattern between \A and \z, so the engine backtracks
    /// for a match that reaches the end, as Regex's wholeMatch(of:) does.
    public func compatWholeMatch(of regex: CompatRegex) -> CompatRegexMatch? {
        let text = String(self)
        let whole = CompatRegex(#"\A(?:"# + regex.expression.pattern + #")\z"#)
        return whole.expression.firstMatch(in: text, range: NSRange(text.startIndex..., in: text))
            .map { CompatRegexMatch($0, in: text) }
    }

    public func compatMatches(of regex: CompatRegex) -> [CompatRegexMatch] {
        let text = String(self)
        let whole = NSRange(text.startIndex..., in: text)
        return regex.expression.matches(in: text, range: whole).map { CompatRegexMatch($0, in: text) }
    }

    public func compatContains(_ regex: CompatRegex) -> Bool {
        let text = String(self)
        return regex.expression.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) != nil
    }
}
