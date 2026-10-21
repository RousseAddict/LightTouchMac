// Big Sur port: replaces upstream's InlineLiveTextView, whose VisionKit overlay (ImageAnalyzer,
// ImageAnalysisOverlayView) is macOS 13. Select Text on Screen is disabled before macOS 13 (patches/09-menus.patch),
// so this is never shown there; it keeps the same surface (init(image:), capturedImage, onClose, stop()) for
// DisplayView, and if it is shown it holds the frozen frame with a Done button and says why there's no text to
// select.
import Cocoa

@MainActor
final class InlineLiveTextView: NSView {
    private let imageView = NSImageView()
    private let doneButton = NSButton(title: "Done", target: nil, action: nil)
    private let statusLabel = NSTextField(labelWithString: "Selecting text on the screen needs macOS 13 or later.")
    var onClose: (() -> Void)?
    let capturedImage: CGImage
    override var isFlipped: Bool { true }

    init(image: CGImage) {
        capturedImage = image
        super.init(frame: .zero)
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.cgColor
        layer?.zPosition = 100
        imageView.image = NSImage(cgImage: image, size: NSSize(width: image.width, height: image.height))
        imageView.imageScaling = .scaleAxesIndependently
        addSubview(imageView)
        doneButton.target = self
        doneButton.action = #selector(done(_:))
        doneButton.bezelStyle = .rounded
        doneButton.keyEquivalent = "\u{1b}"
        doneButton.wantsLayer = true
        doneButton.layer?.zPosition = 200
        addSubview(doneButton)
        statusLabel.textColor = .white
        statusLabel.backgroundColor = .black
        statusLabel.drawsBackground = true
        statusLabel.font = .systemFont(ofSize: 11)
        statusLabel.wantsLayer = true
        statusLabel.layer?.zPosition = 200
        addSubview(statusLabel)
    }

    required init?(coder: NSCoder) { fatalError("not used") }

    override func layout() {
        super.layout()
        imageView.frame = bounds
        doneButton.sizeToFit()
        doneButton.frame.origin = CGPoint(x: bounds.width - doneButton.frame.width - 6, y: 5)
        statusLabel.sizeToFit()
        statusLabel.frame.origin = CGPoint(x: 6, y: bounds.height - statusLabel.frame.height - 6)
    }

    func stop() {
        removeFromSuperview()
    }

    @objc private func done(_ sender: Any?) { onClose?() }
    override func mouseDown(with event: NSEvent) {}
    override func mouseDragged(with event: NSEvent) {}
    override func mouseUp(with event: NSEvent) {}
    override func scrollWheel(with event: NSEvent) {}
    override func magnify(with event: NSEvent) {}
    override func rotate(with event: NSEvent) {}
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { onClose?() } else { super.keyDown(with: event) }
    }
}
