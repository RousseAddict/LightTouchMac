// Big Sur port: macOS 14 AppKit members the app uses, for macOS 11, under compat names (codemod.py renames the uses).
// The app compiles this file; codemod.py links it into each tests/offline target that compiles app files.
import AppKit

extension NSToolbarItem.Identifier {
    /// macOS 14's .inspectorTrackingSeparator: on macOS 11 the toolbar delegate makes it, an NSTrackingSeparatorToolbarItem
    /// over the inspector's divider, as it already does on 14.
    static let compatInspectorTrackingSeparator = NSToolbarItem.Identifier("BigSurInspectorTrackingSeparator")
    /// macOS 14's .toggleInspector: on macOS 11 the toolbar delegate makes it, a button for toggleAppInspector.
    static let compatToggleInspector = NSToolbarItem.Identifier("BigSurToggleInspector")
}

extension NSMenuItem {
    /// macOS 14's sectionHeader(title:): a disabled item in the small bold system font.
    static func compatSectionHeader(title: String) -> NSMenuItem {
        if #available(macOS 14, *) { return .sectionHeader(title: title) }
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        item.isEnabled = false
        item.attributedTitle = NSAttributedString(
            string: title, attributes: [.font: NSFont.boldSystemFont(ofSize: NSFont.smallSystemFontSize)])
        return item
    }
}

extension NSViewController {
    /// macOS 14's loadViewIfNeeded().
    func compatLoadViewIfNeeded() {
        if !isViewLoaded { _ = view }
    }
}

extension NSColor {
    /// macOS 14's systemFill; macOS 11's nearest, a light gray that follows the appearance.
    static var compatSystemFill: NSColor {
        if #available(macOS 14, *) { return .systemFill }
        return .quaternaryLabelColor
    }
}

extension NSWorkspace {
    /// macOS 12's urlsForApplications(toOpen:): Launch Services' apps for the file, the default first.
    func compatURLsForApplications(toOpen url: URL) -> [URL] {
        if #available(macOS 12, *) { return urlsForApplications(toOpen: url) }
        return (LSCopyApplicationURLsForURL(url as CFURL, .all)?.takeRetainedValue() as? [URL]) ?? []
    }
}
