// The part of Sparkle's API Light Touch calls: AppDelegate creates the controller, and the app menu's Check for
// Updates targets it. Nothing checks for updates; the menu item says why.
import AppKit

@objc public protocol SPUUpdaterDelegate {}

@objc public protocol SPUStandardUserDriverDelegate {}

@objc public final class SPUStandardUpdaterController: NSObject {
    public init(
        startingUpdater: Bool,
        updaterDelegate: SPUUpdaterDelegate?,
        userDriverDelegate: SPUStandardUserDriverDelegate?
    ) {
        super.init()
    }

    @MainActor @objc public func checkForUpdates(_ sender: Any?) {
        let alert = NSAlert()
        alert.messageText = "Updates are off in this build"
        alert.informativeText = """
            This is the Big Sur build of Light Touch. Its updates don't come through Light Touch's update feed, \
            whose builds need macOS 14.4: install the next Big Sur build from the port's CI by hand.
            """
        alert.runModal()
    }
}
