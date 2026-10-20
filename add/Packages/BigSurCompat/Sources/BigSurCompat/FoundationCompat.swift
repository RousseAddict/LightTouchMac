// Small macOS 12-13 Foundation and standard library members, for macOS 11.
import Darwin
import Foundation

extension Collection where Element: Equatable {
    /// Stands in for `firstRange(of:)` (macOS 13): the first range of `other`'s elements in this collection.
    public func compatFirstRange<C: Collection>(of other: C) -> Range<Index>? where C.Element == Element {
        searchFirstRange(of: other, in: self)
    }
}

extension Collection where Element == UInt8 {
    /// `compatFirstRange(of:)` for bytes, through memmem when both sides are contiguous: kernels and NOR images are
    /// megabytes long.
    public func compatFirstRange<C: Collection>(of other: C) -> Range<Index>? where C.Element == UInt8 {
        let offset: Int?? = withContiguousStorageIfAvailable { haystack in
            other.withContiguousStorageIfAvailable { needle -> Int? in
                guard let needleBase = needle.baseAddress, needle.count > 0 else { return 0 }
                guard let base = haystack.baseAddress,
                    let match = memmem(base, haystack.count, needleBase, needle.count)
                else { return nil }
                return base.distance(to: match.assumingMemoryBound(to: UInt8.self))
            }
        } ?? nil
        guard let contiguous = offset else { return searchFirstRange(of: other, in: self) }
        guard let found = contiguous else { return nil }
        let lower = index(startIndex, offsetBy: found)
        return lower..<index(lower, offsetBy: other.count)
    }
}

/// The element-by-element search both `compatFirstRange(of:)`s use when memmem can't.
private func searchFirstRange<Base: Collection, C: Collection>(of other: C, in base: Base) -> Range<Base.Index>?
where Base.Element: Equatable, C.Element == Base.Element {
    guard let first = other.first else { return base.startIndex..<base.startIndex }
    var start = base.startIndex
    while let candidate = base[start...].firstIndex(of: first) {
        var i = candidate
        var j = other.startIndex
        while i != base.endIndex, j != other.endIndex, base[i] == other[j] {
            base.formIndex(after: &i)
            other.formIndex(after: &j)
        }
        if j == other.endIndex { return candidate..<i }
        if i == base.endIndex { return nil }
        start = base.index(after: candidate)
    }
    return nil
}

extension TimeZone {
    /// Stands in for `TimeZone.gmt` (macOS 13).
    public static var compatGMT: TimeZone { TimeZone(identifier: "GMT") ?? TimeZone(secondsFromGMT: 0)! }
}
