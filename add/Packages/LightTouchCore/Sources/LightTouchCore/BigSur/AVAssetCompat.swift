// Big Sur port: AVFoundation's async loading (asset.load(.duration), loadTracks(withMediaType:)) is macOS 12. These
// stand-ins load the same keys with loadValuesAsynchronously(forKeys:), which macOS 11 has, and read the values the
// properties name; codemod.py renames MediaSong's and MediaVideo's calls to them. Here rather than in BigSurCompat so
// the helper and the firmwarekit CLI, which re-export that, don't link AVFoundation.
import AVFoundation

/// A property loaded asynchronously, as AVFoundation's AVAsyncProperty: its key and how to read it once loaded.
struct CompatAsyncProperty<Root, Value>: Sendable {
    let key: String
    let read: @Sendable (Root) -> Value
}

extension CompatAsyncProperty where Root == AVAsset, Value == CMTime {
    static var duration: Self { Self(key: "duration") { $0.duration } }
}

extension CompatAsyncProperty where Root == AVAsset, Value == Bool {
    static var hasProtectedContent: Self { Self(key: "hasProtectedContent") { $0.hasProtectedContent } }
}

extension CompatAsyncProperty where Root == AVAsset, Value == [AVMetadataItem] {
    static var commonMetadata: Self { Self(key: "commonMetadata") { $0.commonMetadata } }
    static var metadata: Self { Self(key: "metadata") { $0.metadata } }
}

extension CompatAsyncProperty where Root == AVAssetTrack, Value == [CMFormatDescription] {
    static var formatDescriptions: Self {
        Self(key: "formatDescriptions") { track in track.formatDescriptions.map { $0 as! CMFormatDescription } }
    }
}

extension CompatAsyncProperty where Root == AVMetadataItem, Value == String? {
    static var stringValue: Self { Self(key: "stringValue") { $0.stringValue } }
}

extension CompatAsyncProperty where Root == AVMetadataItem, Value == Data? {
    static var dataValue: Self { Self(key: "dataValue") { $0.dataValue } }
}

extension CompatAsyncProperty where Root == AVMetadataItem, Value == NSNumber? {
    static var numberValue: Self { Self(key: "numberValue") { $0.numberValue } }
}

/// Loads `key` and throws as AVFoundation's load(_:) does: the loading error, or CancellationError.
nonisolated private func compatLoadKey(_ key: String, of object: AVAsynchronousKeyValueLoading) async throws {
    try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
        object.loadValuesAsynchronously(forKeys: [key]) {
            var error: NSError?
            switch object.statusOfValue(forKey: key, error: &error) {
            case .loaded:
                continuation.resume()
            case .cancelled:
                continuation.resume(throwing: CancellationError())
            default:
                continuation.resume(throwing: error ?? AVError(.unknown))
            }
        }
    }
}

extension AVAsset {
    nonisolated func compatLoad<Value>(_ property: CompatAsyncProperty<AVAsset, Value>) async throws -> Value {
        try await compatLoadKey(property.key, of: self)
        return property.read(self)
    }

    /// loadTracks(withMediaType:).
    nonisolated func compatLoadTracks(withMediaType mediaType: AVMediaType) async throws -> [AVAssetTrack] {
        try await compatLoadKey("tracks", of: self)
        return tracks(withMediaType: mediaType)
    }
}

extension AVAssetTrack {
    nonisolated func compatLoad<Value>(_ property: CompatAsyncProperty<AVAssetTrack, Value>) async throws -> Value {
        try await compatLoadKey(property.key, of: self)
        return property.read(self)
    }
}

extension AVMetadataItem {
    nonisolated func compatLoad<Value>(_ property: CompatAsyncProperty<AVMetadataItem, Value>) async throws -> Value {
        try await compatLoadKey(property.key, of: self)
        return property.read(self)
    }
}
