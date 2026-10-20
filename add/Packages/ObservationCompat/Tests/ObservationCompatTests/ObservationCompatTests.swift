// The behaviors Light Touch relies on, through the @CompatObservable macro itself (observation-checks covers the
// runtime by hand on the Big Sur Mac, which can't run macros). Runs on CI.
import ObservationCompat
import Testing

@CompatObservable
final class Car {
    var name = ""
    var miles = 0
    @CompatObservationIgnored var cache = 0
    var label: String { "\(name) \(miles)" }
}

/// EmulatorController's storageFailed: a computed property announced by hand.
@CompatObservable
final class Liveness {
    @CompatObservationIgnored var raw = false

    var storageFailed: Bool {
        access(keyPath: \.storageFailed)
        return raw
    }

    func flip() {
        withMutation(keyPath: \.storageFailed) {}
        raw.toggle()
    }
}

/// Upstream's models are main-actor (LightTouchCore and the app default to it).
@MainActor
@CompatObservable
final class MainActorModel {
    var value = 0
}

final class Fired: @unchecked Sendable {
    var count = 0
}

struct ObservationCompatTests {
    @Test func aChangeToAReadPropertyFiresOnce() {
        let car = Car()
        let fired = Fired()
        withCompatObservationTracking { _ = car.name } onChange: { fired.count += 1 }
        car.miles = 1
        #expect(fired.count == 0)
        car.name = "a"
        car.name = "b"
        #expect(fired.count == 1)
    }

    @Test func anEqualWriteIsSilent() {
        let car = Car()
        let fired = Fired()
        withCompatObservationTracking { _ = car.miles } onChange: { fired.count += 1 }
        car.miles = 0
        #expect(fired.count == 0)
        car.miles = 2
        #expect(fired.count == 1)
    }

    @Test func anIgnoredPropertyIsntTracked() {
        let car = Car()
        let fired = Fired()
        withCompatObservationTracking { _ = car.cache } onChange: { fired.count += 1 }
        car.cache = 5
        #expect(fired.count == 0)
    }

    @Test func aComputedPropertyIsTrackedThroughItsStorage() {
        let car = Car()
        let fired = Fired()
        let label = withCompatObservationTracking { car.label } onChange: { fired.count += 1 }
        #expect(label == " 0")
        car.miles = 3
        #expect(fired.count == 1)
    }

    @Test func aHandAnnouncedMutationFires() {
        let liveness = Liveness()
        let fired = Fired()
        withCompatObservationTracking { _ = liveness.storageFailed } onChange: { fired.count += 1 }
        liveness.flip()
        #expect(fired.count == 1)
        #expect(liveness.storageFailed)
    }

    @Test @MainActor func aMainActorModelIsObservable() {
        let model = MainActorModel()
        let fired = Fired()
        withCompatObservationTracking { _ = model.value } onChange: { fired.count += 1 }
        model.value = 1
        #expect(fired.count == 1)
    }

    @Test func theMacroAddsTheConformance() {
        #expect((Car() as Any) is CompatObservable)
    }
}
