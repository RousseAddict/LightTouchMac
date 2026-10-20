// swift-tools-version: 5.9
// swift-subprocess, as far as Light Touch uses it, for macOS 11: swiftlang/swift-subprocess 1.0.0 needs macOS 13.
// The package keeps its name and the module its name (Subprocess), so upstream's .product(name: "Subprocess",
// package: "swift-subprocess") and `Subprocess.run(...)` resolve here once codemod.py points the manifests and the
// project at this directory. It implements the API surface upstream's call sites use, with 1.0.0's types and
// semantics, on posix_spawn: see Run.swift.
//
// Like 1.0.0, nonisolated async functions run in the caller's isolation (NonisolatedNonsendingByDefault), so the
// closure passed to run(...) does too. The sources stay in Swift 5.5 so the Big Sur Mac builds them and runs
// subprocess-checks against real processes (check/compat.sh).
import PackageDescription

let package = Package(
    name: "swift-subprocess",
    platforms: [.macOS(.v11)],
    products: [.library(name: "Subprocess", targets: ["Subprocess"])],
    dependencies: [.package(path: "../../BigSurCompat")],
    targets: [
        .target(
            name: "Subprocess",
            dependencies: [.product(name: "BigSurCompat", package: "BigSurCompat")],
            swiftSettings: [.enableUpcomingFeature("NonisolatedNonsendingByDefault")]
        ),
        .executableTarget(name: "subprocess-checks", dependencies: ["Subprocess"]),
    ]
)
