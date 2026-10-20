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
        check(TimeZone.compatGMT.identifier == "GMT" && TimeZone.compatGMT.secondsFromGMT() == 0, "TimeZone.compatGMT")
        await sleeping()
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
