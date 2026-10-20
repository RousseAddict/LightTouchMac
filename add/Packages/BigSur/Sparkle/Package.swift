// swift-tools-version: 5.5
// Sparkle, as far as Light Touch uses it, without updating anything. Upstream's update feed serves builds that need
// macOS 14.4, and Sparkle 2.10 itself needs macOS 12, so the Big Sur port swaps the package for this one (codemod.py
// makes the project's reference to Sparkle local). Check for Updates explains where Big Sur builds come from.
import PackageDescription

let package = Package(
    name: "Sparkle",
    platforms: [.macOS(.v11)],
    products: [.library(name: "Sparkle", targets: ["Sparkle"])],
    targets: [.target(name: "Sparkle")]
)
