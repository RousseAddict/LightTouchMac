// Big Sur port: SwiftUI's Map with a Marker, a camera position and MapReader's tap-to-coordinate (macOS 14), for
// macOS 11: an MKMapView with one pin, showing `meters` around `center` whenever `center` changes, that calls `onTap`
// with the coordinate clicked. The app compiles this file; codemod.py links it into the tests/offline targets that
// compile app files.
import AppKit
import MapKit
import SwiftUI

struct CompatMarkerMap: NSViewRepresentable {
    let title: String
    let marker: CLLocationCoordinate2D
    let center: CLLocationCoordinate2D
    let meters: CLLocationDistance
    let onTap: (CLLocationCoordinate2D) -> Void

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeNSView(context: Context) -> RegionMapView {
        let map = RegionMapView()
        map.addGestureRecognizer(
            NSClickGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.clicked(_:))))
        map.addAnnotation(context.coordinator.pin)
        return map
    }

    func updateNSView(_ map: RegionMapView, context: Context) {
        let coordinator = context.coordinator
        coordinator.onTap = onTap
        coordinator.pin.title = title
        coordinator.pin.coordinate = marker
        // Like the camera position it stands for: set when the center changes, so panning and zooming stay until then.
        if coordinator.center?.latitude != center.latitude || coordinator.center?.longitude != center.longitude {
            coordinator.center = center
            map.region(MKCoordinateRegion(center: center, latitudinalMeters: meters, longitudinalMeters: meters))
        }
    }

    /// Sets a region once it has a size: MKMapView fits a region set at zero size to the wrong span and center.
    final class RegionMapView: MKMapView {
        private var pending: MKCoordinateRegion?

        func region(_ region: MKCoordinateRegion) {
            pending = region
            applyPending()
        }

        override func setFrameSize(_ newSize: NSSize) {
            super.setFrameSize(newSize)
            applyPending()
        }

        private func applyPending() {
            guard let region = pending, bounds.width > 0, bounds.height > 0 else { return }
            pending = nil
            setRegion(region, animated: false)
        }
    }

    final class Coordinator: NSObject {
        let pin = MKPointAnnotation()
        var center: CLLocationCoordinate2D?
        var onTap: (CLLocationCoordinate2D) -> Void = { _ in }

        @objc func clicked(_ recognizer: NSClickGestureRecognizer) {
            guard let map = recognizer.view as? MKMapView else { return }
            onTap(map.convert(recognizer.location(in: map), toCoordinateFrom: map))
        }
    }
}
