// swift-tools-version: 6.2
// apple/swift-binary-parsing 0.0.4 (8f0f56a795e36eff6d532b01e8e94f640e3443dd, reviewed in reviewed.json) for macOS 11.
// Upstream declares macOS 13 for the whole package because its macro implementation (BinaryParsingMacros) uses
// Regex; the library itself is built on RawSpan and Span, which the Swift 6.2 runtime back-deploys
// (libswiftCompatibilitySpan). Light Touch uses no BinaryParsing macro, so this package is upstream's BinaryParsing
// target alone: Sources/BinaryParsing and LICENSE.txt are byte for byte that commit's, less Macros/Macros.swift (the
// one #magicNumber declaration, which needed the macro target) and Documentation.docc. The package keeps its name and
// the module its name, so upstream's .product(name: "BinaryParsing", package: "swift-binary-parsing") resolves here
// once codemod.py points FirmwareKit's and LightTouchCore's manifests at this directory.
import PackageDescription

let package = Package(
    name: "swift-binary-parsing",
    platforms: [.macOS(.v11)],
    products: [.library(name: "BinaryParsing", targets: ["BinaryParsing"])],
    targets: [
        .target(
            name: "BinaryParsing",
            swiftSettings: [
                .enableExperimentalFeature("Lifetimes"),
                .strictMemorySafety(),
            ]
        )
    ]
)
