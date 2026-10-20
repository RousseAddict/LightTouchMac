// Checks ObservationCompat's runtime on the system it stands in for: the Big Sur Mac (check/compat.sh, with the
// Command Line Tools' Swift 5.5, which predates macros) and CI. Model spells out by hand what @CompatObservable
// expands to, so these checks need no macro; ObservationCompatTests runs the same behaviors through the macro on
// CI. The behaviors are the ones Light Touch relies on (ObservationLoopTests and the session tests upstream).
// Exits 1 on any failure.
import Foundation
import ObservationCompat

/// What `@CompatObservable final class Model { var count = 0; var name = ""; var other = 0 }` expands to.
final class Model: CompatObservable, @unchecked Sendable {
    private let _$observationRegistrar = CompatObservationRegistrar()

    func access<Member>(keyPath: KeyPath<Model, Member>) {
        _$observationRegistrar.access(self, keyPath: keyPath)
    }

    func withMutation<Member, Result>(keyPath: KeyPath<Model, Member>, _ mutation: () throws -> Result) rethrows
        -> Result
    {
        try _$observationRegistrar.withMutation(of: self, keyPath: keyPath, mutation)
    }

    private func shouldNotifyObservers<Member>(_ lhs: Member, _ rhs: Member) -> Bool { true }
    private func shouldNotifyObservers<Member: Equatable>(_ lhs: Member, _ rhs: Member) -> Bool { lhs != rhs }

    private var _count = 0
    var count: Int {
        get {
            access(keyPath: \.count)
            return _count
        }
        set {
            guard shouldNotifyObservers(_count, newValue) else {
                _count = newValue
                return
            }
            withMutation(keyPath: \.count) { _count = newValue }
        }
    }

    private var _name = ""
    var name: String {
        get {
            access(keyPath: \.name)
            return _name
        }
        set {
            guard shouldNotifyObservers(_name, newValue) else {
                _name = newValue
                return
            }
            withMutation(keyPath: \.name) { _name = newValue }
        }
    }

    private var _other = 0
    var other: Int {
        get {
            access(keyPath: \.other)
            return _other
        }
        set {
            guard shouldNotifyObservers(_other, newValue) else {
                _other = newValue
                return
            }
            withMutation(keyPath: \.other) { _other = newValue }
        }
    }

    /// A computed property: tracked through the stored ones it reads.
    var summary: String { "\(name)=\(count)" }
}

final class Box: @unchecked Sendable {
    var fired = 0
    var seen: [Int] = []
    private let lock = NSLock()
    private var lockedFires = 0

    func fireLocked() {
        lock.lock()
        lockedFires += 1
        lock.unlock()
    }

    var lockedCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return lockedFires
    }
}

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

    static func main() {
        let model = Model()
        let box = Box()

        let read = withCompatObservationTracking { model.count } onChange: { box.fired += 1 }
        check(read == 0, "tracking returns what the closure read")
        model.other = 1
        check(box.fired == 0, "a change to a property it didn't read doesn't fire")
        model.count = 0
        check(box.fired == 0, "writing an equal value doesn't fire")
        model.count = 1
        check(box.fired == 1, "a change to a read property fires")
        model.count = 2
        check(box.fired == 1, "it fires once, then stops")

        box.fired = 0
        withCompatObservationTracking { _ = model.count } onChange: { box.seen.append(model.count) }
        model.count = 3
        check(box.seen == [2], "onChange runs before the new value is stored, as Observation's does")

        box.fired = 0
        _ = withCompatObservationTracking { model.summary } onChange: { box.fired += 1 }
        model.name = "a"
        check(box.fired == 1, "a computed property is tracked through what it reads")

        box.fired = 0
        let second = Model()
        withCompatObservationTracking {
            _ = model.count
            _ = second.name
        } onChange: { box.fired += 1 }
        second.name = "b"
        model.count = 4
        check(box.fired == 1, "one tracking spans several objects, and fires once")

        box.fired = 0
        withCompatObservationTracking {
            withCompatObservationTracking { _ = model.other } onChange: {}
        } onChange: { box.fired += 1 }
        model.other = 2
        check(box.fired == 1, "an inner tracking's reads also count for the outer one")

        box.fired = 0
        withCompatObservationTracking { _ = model.name } onChange: { box.fired += 1 }
        _ = withCompatObservationTracking { 0 } onChange: { box.fired += 100 }
        model.name = "c"
        check(box.fired == 1, "a tracking that read nothing never fires")

        withCompatObservationTracking { _ = model.count } onChange: { box.fireLocked() }
        DispatchQueue.concurrentPerform(iterations: 8) { i in
            for j in 0..<1_000 { model.count = 10_000 + i * 1_000 + j }
        }
        // Swift's Observation copies the observers under its lock and calls them outside it, cancelling the
        // tracking after the call, so writers on several threads at once can each fire it before it's cancelled.
        // Light Touch's models are main-actor; what holds is that it fires and then stays cancelled.
        let firedConcurrently = box.lockedCount
        model.count = -1
        check(firedConcurrently >= 1 && box.lockedCount == firedConcurrently,
              "concurrent writers fire a tracking, then it stays cancelled (fired \(firedConcurrently)x)")

        var tracked: Model? = Model()
        weak var weakModel = tracked
        withCompatObservationTracking { _ = tracked?.count } onChange: { box.fired += 1 }
        tracked = nil
        check(weakModel == nil, "tracking doesn't keep the object alive")

        print(failures == 0 ? "\nAll checks passed." : "\n\(failures) checks failed.")
        exit(failures == 0 ? 0 : 1)
    }
}
