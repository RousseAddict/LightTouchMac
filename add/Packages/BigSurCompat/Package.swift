// swift-tools-version: 5.5
// BigSurCompat: macOS 11 stand-ins for the macOS 12-14 APIs Light Touch uses. The Big Sur port's codemod renames
// upstream's uses to these (Duration to CompatDuration and so on); HostRuntime and HostServiceWire re-export the
// module. It needs only Foundation, CoreVideo and os, and stays in Swift 5.5 so the Big Sur Mac's Command Line Tools
// build it and run compat-checks there, on the system it stands in for.
import PackageDescription

let package = Package(
    name: "BigSurCompat",
    platforms: [.macOS(.v11)],
    products: [.library(name: "BigSurCompat", type: .static, targets: ["BigSurCompat"])],
    targets: [
        .target(name: "BigSurCompat"),
        .executableTarget(name: "compat-checks", dependencies: ["BigSurCompat"]),
    ]
)
