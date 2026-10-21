// Big Sur port: replaces upstream's CanvasCapture, which crops this app's device window through ScreenCaptureKit
// (macOS 12.3; its own-process content and screenshot calls are 14 and 14.4). macOS 11 has CGWindowListCreateImage,
// which captures a window of this app without asking for screen recording permission: the same crop (the device
// pane's safe area, without window chrome), at the window's backing scale, in even pixel sizes for the movie writer.
// A recording takes a frame on a queue of its own about 30 times a second and follows the pane as the window moves
// or resizes.
import AppKit
import BigSurCompat
import HostRuntime
import LightTouchCore

@MainActor
final class CanvasCapture {
    private weak var view: NSView?
    private let profile: Board
    private let frames = CanvasFrames()
    private var refresh: Task<Void, Never>?
    private(set) var outputSize = CGSize.zero

    init(view: NSView, profile: Board) {
        self.view = view
        self.profile = profile
    }

    /// The window, the device pane in CGWindowList's global coordinates (top-left origin, in points), and the
    /// pixel size a frame of it has.
    private func region() throws -> CanvasRegion {
        guard let view, let window = view.window, window.isVisible, !window.isMiniaturized,
            view.bounds.width > 1, view.bounds.height > 1
        else {
            throw CaptureError.failed("Open the \(profile.shortName) window to capture it.")
        }
        let onScreen = window.convertToScreen(view.convert(view.safeAreaRect, to: nil))
        // Global display coordinates run down from the top of the main display (the one at the Cocoa origin).
        let top = NSScreen.screens.first?.frame.maxY ?? onScreen.maxY
        let scale = window.backingScaleFactor
        return CanvasRegion(
            window: CGWindowID(window.windowNumber),
            rect: CGRect(x: onScreen.minX, y: top - onScreen.maxY, width: onScreen.width, height: onScreen.height),
            size: CGSize(
                width: max(2, Int(onScreen.width * scale) / 2 * 2),
                height: max(2, Int(onScreen.height * scale) / 2 * 2)
            )
        )
    }

    func screenshot() async throws -> CGImage {
        guard let image = try region().capture() else { throw CaptureError.failed("Couldn’t capture the screen.") }
        return image
    }

    func start() async throws {
        let first = try region()
        outputSize = first.size
        frames.start(first)
        // Wait for an actual frame; none is no recording.
        for _ in 0..<120 {
            try Task.checkCancellation()
            if frames.image != nil { break }
            if let error = frames.failure { throw error }
            try await Task.compatSleep(for: .milliseconds(16))
        }
        guard frames.image != nil else {
            await stop()
            throw CaptureError.failed("Couldn’t capture the screen.")
        }
        refresh = Task { [weak self] in
            while !Task.isCancelled {
                do { try await Task.compatSleep(for: .milliseconds(50)) } catch { return }
                guard let self else { return }
                do { frames.follow(try region()) } catch {
                    frames.fail(error)
                    return
                }
            }
        }
    }

    func frame() throws -> CGImage? {
        if let error = frames.failure { throw error }
        // Until a frame of the pane as it is now arrives, none: an old crop could show window chrome.
        frames.follow(try region())
        return frames.image
    }

    func stop() async {
        refresh?.cancel()
        refresh = nil
        frames.stop()
    }
}

/// What to capture: a window of this app, the rect of it, and the frame's pixel size.
private struct CanvasRegion: Equatable, Sendable {
    let window: CGWindowID
    let rect: CGRect
    let size: CGSize

    nonisolated func capture() -> CGImage? {
        guard
            let image = CGWindowListCreateImage(
                rect, .optionIncludingWindow, window, [.boundsIgnoreFraming, .bestResolution])
        else { return nil }
        let crop = CGRect(
            x: 0, y: 0, width: min(CGFloat(image.width), size.width), height: min(CGFloat(image.height), size.height))
        return image.cropping(to: crop) ?? image
    }
}

/// The latest frame of the region, taken on a queue of its own; consumers copy an immutable image.
private nonisolated final class CanvasFrames: @unchecked Sendable {
    private let queue = DispatchQueue(label: "app.lighttouch.canvas-capture", qos: .userInitiated)
    private let lock = NSLock()
    private var region: CanvasRegion?
    private var latest: CGImage?
    private var error: Error?
    private var generation = 0

    var image: CGImage? { lock.withLock { latest } }
    var failure: Error? { lock.withLock { error } }

    func start(_ region: CanvasRegion) {
        let generation: Int = lock.withLock {
            self.region = region
            latest = nil
            error = nil
            self.generation += 1
            return self.generation
        }
        queue.async { [self] in run(generation) }
    }

    /// Captures `region` from now on, dropping the frame of an older one.
    func follow(_ region: CanvasRegion) {
        lock.withLock {
            guard self.region != nil, self.region != region else { return }
            self.region = region
            latest = nil
        }
    }

    func fail(_ error: Error) { lock.withLock { self.error = error } }

    func stop() {
        lock.withLock {
            region = nil
            latest = nil
            generation += 1
        }
    }

    private func run(_ generation: Int) {
        while true {
            let started = DispatchTime.now()
            guard let region = lock.withLock({ self.generation == generation ? self.region : nil }) else { return }
            let image = region.capture()
            lock.withLock {
                if self.generation == generation, self.region == region, let image { latest = image }
            }
            let elapsed = DispatchTime.now().uptimeNanoseconds - started.uptimeNanoseconds
            if elapsed < 33_000_000 { usleep(useconds_t((33_000_000 - elapsed) / 1000)) }
        }
    }
}
