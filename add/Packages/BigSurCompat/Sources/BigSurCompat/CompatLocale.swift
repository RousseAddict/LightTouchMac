// macOS 13's Locale.Language, Locale.region and Locale.identifier(.icu, from:), as Light Touch uses them to pick a
// prepared device's language, region and keyboards, for macOS 11. The likely-subtags and identifier conversions call
// the same ICU (libicucore, in every macOS) Foundation's newer API reads; compat-checks compares the two on CI, where
// both exist, and runs these on the Big Sur Mac.
import Darwin
import Foundation

extension Locale {
    /// `language.languageCode?.identifier`.
    public var compatLanguageCode: String? { languageCode }

    /// `region?.identifier`: the region override where the identifier has one ("de_DE@rg=chzzzz" is CH), else its
    /// country or area code ("en_US" is US, "es_419" is 419).
    public var compatRegionIdentifier: String? {
        if let override = Locale.components(fromIdentifier: identifier)["rg"] {
            let digits = override.prefix { $0.isNumber }
            if digits.count == 3 { return String(digits) }
            if override.count >= 2 { return override.prefix(2).uppercased() }
        }
        return regionCode
    }

    /// `Locale.identifier(.icu, from:)`: "en-US" is en_US, "de-DE-u-rg-chzzzz" de_DE@rg=chzzzz, an ICU identifier
    /// stays as it is.
    public static func compatICUIdentifier(from string: String) -> String {
        if string.contains("-"), let converted = ICU.forLanguageTag(string) { return converted }
        return ICU.canonicalize(string) ?? string
    }

    /// The language code, script and region of `Locale.Language(identifier:).maximalIdentifier`: ICU's likely
    /// subtags ("zh" is zh, Hans, CN; "zh_TW" zh, Hant, TW).
    public static func compatMaximal(_ language: String) -> (languageCode: String?, script: String?, region: String?) {
        let maximal = ICU.addLikelySubtags(compatICUIdentifier(from: language)) ?? language
        let parts = Locale.components(fromIdentifier: maximal)
        return (
            parts[NSLocale.Key.languageCode.rawValue], parts[NSLocale.Key.scriptCode.rawValue],
            parts[NSLocale.Key.countryCode.rawValue]
        )
    }
}

/// The few ICU C functions this needs, looked up in libicucore, whose names macOS exports unversioned.
private enum ICU {
    typealias Convert = @convention(c) (
        UnsafePointer<CChar>, UnsafeMutablePointer<CChar>, Int32, UnsafeMutablePointer<Int32>
    ) -> Int32
    typealias FromTag = @convention(c) (
        UnsafePointer<CChar>, UnsafeMutablePointer<CChar>, Int32, UnsafeMutablePointer<Int32>,
        UnsafeMutablePointer<Int32>
    ) -> Int32

    static let library = dlopen("/usr/lib/libicucore.A.dylib", RTLD_LAZY)

    static func function<T>(_ name: String, as type: T.Type) -> T? {
        dlsym(library, name).map { unsafeBitCast($0, to: type) }
    }

    static func call(_ convert: Convert?, _ input: String) -> String? {
        guard let convert = convert else { return nil }
        var output = [CChar](repeating: 0, count: 256)
        var status: Int32 = 0
        let length = input.withCString { convert($0, &output, Int32(output.count), &status) }
        guard status <= 0, length > 0, length < output.count else { return nil }  // U_ZERO_ERROR or a warning
        return String(cString: output)
    }

    static func addLikelySubtags(_ id: String) -> String? {
        call(function("uloc_addLikelySubtags", as: Convert.self), id)
    }

    static func canonicalize(_ id: String) -> String? {
        call(function("uloc_canonicalize", as: Convert.self), id)
    }

    static func forLanguageTag(_ tag: String) -> String? {
        guard let convert = function("uloc_forLanguageTag", as: FromTag.self) else { return nil }
        var output = [CChar](repeating: 0, count: 256)
        var parsed: Int32 = 0
        var status: Int32 = 0
        let length = tag.withCString { convert($0, &output, Int32(output.count), &parsed, &status) }
        guard status <= 0, length > 0, length < output.count, Int(parsed) == tag.utf8.count else { return nil }
        return String(cString: output)
    }
}
