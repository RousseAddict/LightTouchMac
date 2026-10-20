// Checks BigSurCompat's stand-ins against the behavior of the APIs they replace. It runs on the Big Sur Mac with the
// Command Line Tools (bigsur/check/compat.sh) and on CI, and exits 1 on any failure. --display also checks
// CompatDisplayLink, which needs a display.
import BigSurCompat
import Foundation

@main
struct Checks {
    static var failures = 0

    static func check(_ condition: Bool, _ what: String, line: UInt = #line) {
        if condition {
            print("ok    \(what)")
        } else {
            failures += 1
            print("FAIL  \(what) (Checks.swift:\(line))")
        }
    }

    static func main() async {
        duration()
        instants()
        lock()
        firstRange()
        regex()
        locale()
        formats()
        check(TimeZone.compatGMT.identifier == "GMT" && TimeZone.compatGMT.secondsFromGMT() == 0, "TimeZone.compatGMT")
        await sleeping()
        await network()
        if CommandLine.arguments.contains("--display") { await displayLink() }
        print(failures == 0 ? "\nAll checks passed." : "\n\(failures) checks failed.")
        exit(failures == 0 ? 0 : 1)
    }

    static func duration() {
        check(CompatDuration.seconds(5).nanoseconds == 5_000_000_000, "Duration.seconds(Int)")
        check(CompatDuration.seconds(1.5) == .milliseconds(1500), "Duration.seconds(Double)")
        check(CompatDuration.milliseconds(250) + .milliseconds(750) == .seconds(1), "Duration +")
        check(CompatDuration.milliseconds(999) < .seconds(1), "Duration <")
        var remaining = CompatDuration.seconds(2)
        remaining -= .milliseconds(500)
        check(remaining == .milliseconds(1500), "Duration -=")
        check(CompatDuration.seconds(5).description == "5.0 seconds", "Duration description, whole")
        check(CompatDuration.milliseconds(1500).description == "1.5 seconds", "Duration description, fraction")
        check(CompatDuration.zero.description == "0.0 seconds", "Duration description, zero")
        let parts = CompatDuration.milliseconds(1500).components
        check(parts.seconds == 1 && parts.attoseconds == 500_000_000_000_000_000, "Duration components")
        check(CompatDuration.milliseconds(Int(0.25 * 1000)).timeInterval == 0.25, "Duration from a TimeInterval")
        check(CompatDuration.seconds(3) / CompatDuration.seconds(2) == 1.5, "Duration / Duration")
        check(Set([CompatDuration.seconds(1), .milliseconds(1000)]).count == 1, "Duration Hashable")
    }

    static func instants() {
        let a = CompatContinuousClock.now
        let b = CompatContinuousClock().now
        check(b >= a, "ContinuousClock is monotonic")
        check((a + .seconds(1)) - a == .seconds(1), "Instant + Duration - Instant")
        check(a.advanced(by: .milliseconds(5)).duration(to: a) == .milliseconds(-5), "Instant advanced/duration(to:)")
        let s = CompatSuspendingClock.now
        check(CompatSuspendingClock.Instant.now >= s, "SuspendingClock is monotonic")
        var deadline = s
        deadline += .seconds(2)
        check(deadline - s == .seconds(2), "Instant +=")
    }

    static func lock() {
        let counter = CompatUnfairLock(initialState: 0)
        DispatchQueue.concurrentPerform(iterations: 8) { _ in
            for _ in 0..<10_000 { counter.withLock { $0 += 1 } }
        }
        check(counter.withLock { $0 } == 80_000, "UnfairLock serializes 8 threads")
        struct Failure: Error {}
        let threw = (try? counter.withLock { _ -> Int in throw Failure() }) == nil
        check(threw && counter.withLockUnchecked { $0 } == 80_000, "UnfairLock rethrows and keeps its state")
        let unchecked = CompatUnfairLock<NSMutableArray?>(uncheckedState: nil)
        unchecked.withLockUnchecked { $0 = NSMutableArray(object: 1) }
        check(unchecked.withLock { $0?.count } == 1, "UnfairLock(uncheckedState:)")
        let void = CompatUnfairLock()
        check(void.withLock { 7 } == 7, "UnfairLock<Void>")
    }

    static func firstRange() {
        let bytes: [UInt8] = [1, 2, 3, 4, 2, 3]
        check(bytes.compatFirstRange(of: [2, 3]) == 1..<3, "firstRange, bytes")
        check(bytes.compatFirstRange(of: [3, 4, 2]) == 2..<5, "firstRange, bytes, middle")
        check(bytes.compatFirstRange(of: [9]) == nil, "firstRange, bytes, absent")
        check(bytes.compatFirstRange(of: [2, 3, 5]) == nil, "firstRange, bytes, runs past the end")
        check(bytes.compatFirstRange(of: [UInt8]()) == 0..<0, "firstRange, bytes, empty needle")
        check(bytes[2...].compatFirstRange(of: [2, 3]) == 4..<6, "firstRange, slice keeps the base's indices")
        check(Data([0, 1, 2, 3]).compatFirstRange(of: Data([2, 3])) == 2..<4, "firstRange, Data")
        let reversed = (0..<10).map { UInt8($0) }.reversed()
        if let found = reversed.compatFirstRange(of: [5, 4]) {
            check(Array(reversed[found]) == [5, 4], "firstRange, bytes that aren't contiguous")
        } else {
            check(false, "firstRange, bytes that aren't contiguous")
        }
        let text = "hello world"
        check(text.compatFirstRange(of: "o w").map { String(text[$0]) } == "o w", "firstRange, String")
        let big = [UInt8](repeating: 0, count: 8 << 20) + Array("Darwin Kernel Version".utf8)
        check(big.compatFirstRange(of: Array("Darwin".utf8))?.lowerBound == 8 << 20, "firstRange, 8 MiB through memmem")
    }

    /// Light Touch's own patterns, on the text they read.
    static func regex() {
        let gles = CompatRegex(#"(?m)^GLES_FN\(\w+,\s*(\w+),"#)
        let table = "GLES_FN(void, glFoo, (int)),\nGLES_FN(int,  glBar, ()),\n  GLES_FN(int, glIndented, ()),"
        check(table.compatMatches(of: gles).map { String($0[1]) } == ["glFoo", "glBar"], "Regex matches(of:), (?m)^")
        let folders = CompatRegex(#"Incorrect folder count in a directory \(id = (\d+)\)"#)
        check(UInt32("Incorrect folder count in a directory (id = 1234)".compatWholeMatch(of: folders)?[1] ?? "")
                == 1234, "Regex wholeMatch(of:) and a group")
        check("x Incorrect folder count in a directory (id = 1)".compatWholeMatch(of: folders) == nil,
              "wholeMatch(of:) needs the whole string")
        check("ab".compatWholeMatch(of: CompatRegex("a|ab")) != nil, "wholeMatch(of:) backtracks to reach the end")
        let crash = CompatRegex(#"^(.+?)[_-]\d{4}-\d{2}-\d{2}-\d{6}"#)
        check("SpringBoard_2026-10-20-123456_iPod.plist".compatFirstMatch(of: crash)?[1] == "SpringBoard",
              "Regex firstMatch(of:), a lazy group")
        check("a_b_2026-01-01-000000".compatFirstMatch(of: crash)?[1] == "a_b", "a lazy group backtracks")
        let failure = CompatRegex(#"(?i)error|fail|couldn[’']t|can[’']t|crash|refused|didn[’']t|unexpected"#)
        check("Couldn’t open".compatContains(failure) && "ERROR here"[...].compatContains(failure)
                && !"all good".compatContains(failure), "Regex contains, (?i) and a curly apostrophe")
        let kernel = "junk\u{0}Darwin Kernel Version 10.0.0: xnu\u{0}more"
        check(kernel.compatFirstMatch(of: CompatRegex(#"Darwin Kernel Version [^\x00]+"#))?.output
                == "Darwin Kernel Version 10.0.0: xnu", "Regex [^\\x00]+ stops at a NUL")
        check("..iBoot-636.66.3x".compatFirstMatch(of: CompatRegex(#"iBoot-[0-9.]+"#))?.output == "iBoot-636.66.3",
              "Regex output")
        let identifying = CompatRegex("ecid|imei|iccid|meid|serial|mac|uid")
        check("ecid".compatContains(identifying) && !"board".compatContains(identifying), "Regex contains, plain")
    }

    /// What picks a prepared device's language, region and keyboards (ClockRegion, FinishedSetup, Keyboards).
    static func locale() {
        let zh = Locale.compatMaximal("zh")
        check(zh.languageCode == "zh" && zh.script == "Hans" && zh.region == "CN", "likely subtags: zh")
        let tw = Locale.compatMaximal("zh_TW")
        check(tw.script == "Hant" && tw.region == "TW", "likely subtags: zh_TW")
        check(Locale.compatMaximal("zh-Hant").region == "TW", "likely subtags: zh-Hant (a BCP 47 tag)")
        check(Locale.compatMaximal("ja").script == "Jpan" && Locale.compatMaximal("sr").script == "Cyrl",
              "likely subtags: ja, sr")
        check(Locale(identifier: "de_DE@rg=chzzzz").compatRegionIdentifier == "CH", "region honors @rg=")
        check(Locale(identifier: "en_US").compatRegionIdentifier == "US"
                && Locale(identifier: "es_419").compatRegionIdentifier == "419"
                && Locale(identifier: "fr").compatRegionIdentifier == nil, "region: country, area, none")
        check(Locale(identifier: "zh-Hans_CN").compatLanguageCode == "zh", "language code")
        check(Locale.compatICUIdentifier(from: "en-US") == "en_US"
                && Locale.compatICUIdentifier(from: "zh-Hans-CN") == "zh_Hans_CN", "ICU identifier from BCP 47")
        check(Locale.compatICUIdentifier(from: "de-DE-u-rg-chzzzz") == "de_DE@rg=chzzzz",
              "ICU identifier keeps a region override")
        check(Locale.compatICUIdentifier(from: "de_DE@rg=chzzzz") == "de_DE@rg=chzzzz"
                && Locale.compatICUIdentifier(from: "uk_UA") == "uk_UA", "an ICU identifier stays")
        #if compiler(>=5.7)
            if #available(macOS 13, *) {
                // Where both exist (CI), the stand-ins answer as macOS 13's API does.
                let identifiers = [
                    "en", "en_US", "en-GB", "fr_CA", "de_DE@rg=chzzzz", "zh", "zh-Hans", "zh_TW", "zh-Hant-HK",
                    "ja_JP", "ko", "sr", "sr-Latn", "uk_UA", "pt-BR", "es_419", "az-Cyrl", "nb", "he_IL", "ar",
                ]
                var differences: [String] = []
                for id in identifiers {
                    let locale = Locale(identifier: id)
                    let modern = Locale.Language(identifier: Locale.Language(identifier: id).maximalIdentifier)
                    let compat = Locale.compatMaximal(id)
                    if locale.compatLanguageCode != locale.language.languageCode?.identifier { differences.append("\(id) language") }
                    if locale.compatRegionIdentifier != locale.region?.identifier { differences.append("\(id) region") }
                    if compat.languageCode != modern.languageCode?.identifier || compat.script != modern.script?.identifier
                        || compat.region != modern.region?.identifier
                    {
                        differences.append("\(id) maximal \(compat) vs \(modern.maximalIdentifier)")
                    }
                    if Locale.compatICUIdentifier(from: id) != Locale.identifier(.icu, from: id) {
                        differences.append("\(id) icu \(Locale.compatICUIdentifier(from: id)) vs \(Locale.identifier(.icu, from: id))")
                    }
                }
                check(differences.isEmpty, "Locale stand-ins match macOS 13's API on \(identifiers.count) identifiers \(differences)")
            }
        #endif
    }

    static func formats() {
        let date = Date(timeIntervalSince1970: 1_307_448_000)  // 2011-06-07 12:00:00 UTC
        check(CompatFormat.iso8601(date) == "2011-06-07T12:00:00Z", "ISO8601Format()")
        check(CompatFormat.iso8601Day(date) == "2011-06-07", ".iso8601.year().month().day()")
        check(CompatFormat.parseISO8601("2011-06-07T12:00:00Z") == date, "Date(_:strategy: .iso8601)")
        check(CompatFormat.parseISO8601("June") == nil, "an unparseable date is nil")
        check(!CompatFormat.fileBytes(12_345_678_901 as Int64).isEmpty && !CompatFormat.decimal(1_048_576).isEmpty
                && !CompatFormat.longDate(date, timeZone: .compatGMT).isEmpty, "byte count, decimal, long date")
        #if compiler(>=5.7)
            if #available(macOS 12, *) {
                // Where both exist (CI), the formatters give FormatStyle's text.
                var differences: [String] = []
                // Known and cosmetic: FormatStyle writes kB and rounds 999 bytes up to 1 kB; ByteCountFormatter, the
                // only one macOS 11 has, writes KB and 999 bytes. Reported, not failed.
                var bytesNotes: [String] = []
                for bytes: Int64 in [0, 999, 1_000, 123_456_789, 12_345_678_901, 3_000_000_000_000] {
                    let style = bytes.formatted(.byteCount(style: .file))
                    if CompatFormat.fileBytes(bytes) != style { bytesNotes.append("\(CompatFormat.fileBytes(bytes)) vs \(style)") }
                }
                if !bytesNotes.isEmpty { print("note  byte counts differ cosmetically from FormatStyle: \(bytesNotes)") }
                for value in [0, 999, 1_048_576, -42] where CompatFormat.decimal(value) != value.formatted() {
                    differences.append("\(value): \(CompatFormat.decimal(value)) vs \(value.formatted())")
                }
                if CompatFormat.iso8601(date) != date.ISO8601Format() { differences.append("ISO8601Format") }
                if CompatFormat.iso8601Day(date) != date.formatted(.iso8601.year().month().day()) {
                    differences.append("iso8601 day: \(date.formatted(.iso8601.year().month().day()))")
                }
                let long = date.formatted(Date.FormatStyle(date: .long, time: .omitted, timeZone: .compatGMT))
                if CompatFormat.longDate(date, timeZone: .compatGMT) != long { differences.append("long date: \(long)") }
                check(differences.isEmpty, "formatters match FormatStyle \(differences)")
            }
        #endif
    }

    static func sleeping() async {
        for clock in [CompatSleepClock.continuous, .suspending] {
            let start = CompatContinuousClock.now
            try? await Task.compatSleep(for: .milliseconds(100), clock: clock)
            let elapsed = CompatContinuousClock.now - start
            check(elapsed >= .milliseconds(95) && elapsed < .seconds(1), "Task.compatSleep(for:clock: .\(clock))")
        }
        let start = CompatContinuousClock.now
        try? await Task.compatSleep(for: .milliseconds(-5))
        check(CompatContinuousClock.now - start < .milliseconds(50), "Task.compatSleep returns at once when negative")
        let clock = CompatContinuousClock()
        let until = clock.now + .milliseconds(60)
        try? await clock.sleep(until: until)
        check(clock.now >= until, "ContinuousClock.sleep(until:)")
        let sleeper = Task { () -> Bool in
            do {
                try await Task.compatSleep(for: .seconds(5))
                return false
            } catch {
                return error is CancellationError
            }
        }
        try? await Task.compatSleep(for: .milliseconds(50))
        let cancelled = CompatContinuousClock.now
        sleeper.cancel()
        let threw = await sleeper.value
        check(threw && CompatContinuousClock.now - cancelled < .seconds(1), "Task.compatSleep throws on cancellation")
    }

    /// Against file URLs, which URLSession serves like any other: no network needed.
    static func network() async {
        final class Progress: NSObject, URLSessionDownloadDelegate, @unchecked Sendable {
            var written: Int64 = 0
            var finished = false
            func urlSession(_ s: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo l: URL) {
                finished = true
            }
            func urlSession(_ s: URLSession, downloadTask: URLSessionDownloadTask, didWriteData b: Int64,
                            totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) { written = totalBytesWritten }
        }
        let source = FileManager.default.temporaryDirectory.appendingPathComponent("compat-net-\(getpid()).bin")
        let payload = Data((0..<300_000).map { UInt8($0 % 251) })
        try? payload.write(to: source)
        defer { try? FileManager.default.removeItem(at: source) }
        do {
            let (data, _) = try await URLSession.shared.compatData(for: URLRequest(url: source))
            check(data == payload, "URLSession.compatData(for:)")
            let progress = Progress()
            let (file, _) = try await URLSession.shared.compatDownload(for: URLRequest(url: source), delegate: progress)
            defer { try? FileManager.default.removeItem(at: file) }
            check((try? Data(contentsOf: file)) == payload && progress.finished,
                  "URLSession.compatDownload(for:delegate:) keeps the file and tells the delegate")
        } catch {
            check(false, "URLSession stand-ins: \(error)")
        }
        do {
            _ = try await URLSession.shared.compatData(for: URLRequest(url: URL(fileURLWithPath: "/nonexistent")))
            check(false, "compatData throws for a missing file")
        } catch {
            check(true, "compatData throws for a missing file")
        }
    }

    /// Ticks arrive through the main queue, so the check awaits rather than blocking the main thread.
    static func displayLink() async {
        final class Counter: NSObject {
            var ticks = 0
            @objc func step(_ link: CompatDisplayLink) { ticks += 1 }
        }
        let counter = Counter()
        let link = CompatDisplayLink(target: counter, selector: #selector(Counter.step(_:)))
        link.add(to: .main, forMode: .common)
        try? await Task.compatSleep(for: .milliseconds(500))
        let ticks = counter.ticks
        check(ticks >= 10, "CompatDisplayLink ticks on the main thread (\(ticks) in 0.5 s)")
        check(link.timestamp > 0, "CompatDisplayLink timestamp")
        link.invalidate()
        try? await Task.compatSleep(for: .milliseconds(100))
        let after = counter.ticks
        try? await Task.compatSleep(for: .milliseconds(200))
        check(counter.ticks == after, "CompatDisplayLink stops after invalidate()")
    }
}
