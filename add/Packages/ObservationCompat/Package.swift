// swift-tools-version: 5.9
// ObservationCompat: Swift 6.2's Observation, for macOS 11, which lacks the system's (macOS 14). The runtime is
// swiftlang/swift release/6.2's stdlib/public/Observation with its C++ lock and thread-local shims written in Swift;
// the macros are that release's lib/Macros/Sources/ObservationMacros with the names prefixed Compat. The Big Sur
// port's codemod renames upstream's @Observable, @ObservationIgnored and withObservationTracking to these, so the
// app keeps Observation's exact semantics: per-property tracking, through computed properties, with equal-value
// writes left silent.
//
// The runtime stays in Swift 5.5 so the Big Sur Mac builds it and runs observation-checks there (check/compat.sh);
// the macros and the tests that use them build on CI.
import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "ObservationCompat",
    platforms: [.macOS(.v11)],
    products: [.library(name: "ObservationCompat", type: .static, targets: ["ObservationCompat"])],
    dependencies: [.package(url: "https://github.com/swiftlang/swift-syntax.git", exact: "602.0.0")],
    targets: [
        .macro(
            name: "ObservationCompatMacros",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .target(name: "ObservationCompat", dependencies: ["ObservationCompatMacros"]),
        .executableTarget(name: "observation-checks", dependencies: ["ObservationCompat"]),
        .testTarget(name: "ObservationCompatTests", dependencies: ["ObservationCompat"]),
    ]
)
