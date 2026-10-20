// macOS 14's NSView.displayLink(target:selector:) for macOS 11: a CVDisplayLink that sends the selector to the target
// on the main thread once per refresh. Like CADisplayLink, it retains its target until it's invalidated. It
// follows the display it's given rather than the view's window, so the view calls setDisplay(_:) when it changes
// screens. Ticks the main thread hasn't run yet don't pile up: there is at most one waiting.
import CoreVideo
import Foundation

public final class CompatDisplayLink: NSObject {
    private var target: NSObject?
    private let selector: Selector
    private var link: CVDisplayLink?
    private let pending = CompatUnfairLock(initialState: false)

    /// The host time of the latest refresh, in seconds, as CADisplayLink's `timestamp`.
    public private(set) var timestamp: CFTimeInterval = 0

    public init(target: NSObject, selector: Selector) {
        self.target = target
        self.selector = selector
        super.init()
    }

    deinit {
        if let link = link { CVDisplayLinkStop(link) }
    }

    /// Starts the ticks. The run loop and mode are accepted for CADisplayLink's shape; ticks come through the main
    /// queue, which the main run loop serves in its common modes.
    public func add(to runLoop: RunLoop, forMode mode: RunLoop.Mode) {
        guard link == nil, target != nil else { return }
        var created: CVDisplayLink?
        guard CVDisplayLinkCreateWithActiveCGDisplays(&created) == kCVReturnSuccess, let link = created else { return }
        let context = Unmanaged.passUnretained(self).toOpaque()
        CVDisplayLinkSetOutputCallback(link, { _, now, _, _, _, context in
            guard let context = context else { return kCVReturnSuccess }
            let displayLink = Unmanaged<CompatDisplayLink>.fromOpaque(context).takeUnretainedValue()
            displayLink.tick(hostTime: now.pointee.hostTime)
            return kCVReturnSuccess
        }, context)
        self.link = link
        CVDisplayLinkStart(link)
    }

    /// Follows `display` (the screen the view is on), for its refresh rate and timing.
    public func setDisplay(_ display: CGDirectDisplayID) {
        guard let link = link else { return }
        CVDisplayLinkSetCurrentCGDisplay(link, display)
    }

    public var isPaused: Bool {
        get { link.map { !CVDisplayLinkIsRunning($0) } ?? true }
        set {
            guard let link = link else { return }
            if newValue { CVDisplayLinkStop(link) } else { CVDisplayLinkStart(link) }
        }
    }

    /// Stops the ticks and releases the target.
    public func invalidate() {
        if let link = link { CVDisplayLinkStop(link) }
        link = nil
        target = nil
    }

    private func tick(hostTime: UInt64) {
        let alreadyWaiting = pending.withLock { waiting -> Bool in
            defer { waiting = true }
            return waiting
        }
        guard !alreadyWaiting else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.pending.withLock { $0 = false }
            guard let target = self.target else { return }
            self.timestamp = Self.seconds(hostTime: hostTime)
            target.perform(self.selector, with: self)
        }
    }

    private static let timebase: mach_timebase_info_data_t = {
        var info = mach_timebase_info_data_t()
        mach_timebase_info(&info)
        return info
    }()

    private static func seconds(hostTime: UInt64) -> CFTimeInterval {
        Double(hostTime) * Double(timebase.numer) / Double(timebase.denom) / 1e9
    }
}
