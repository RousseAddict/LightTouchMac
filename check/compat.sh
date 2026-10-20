#!/bin/bash
# Builds BigSurCompat and its checks with whatever swiftc is installed, and runs them. On the Big Sur Mac that is the
# Command Line Tools' Swift 5.5, whose SwiftPM won't build without XCTest (it ships with Xcode only), so this calls
# swiftc directly. The checks link the back-deployed Swift concurrency library from the toolchain, as the app's
# bundle carries it. Pass --display to also check CompatDisplayLink against the Mac's display.
#
#   check/compat.sh [--display]
set -euo pipefail
HERE=$(cd "$(dirname "$0")/.." && pwd)
PACKAGE="$HERE/add/Packages/BigSurCompat"
BUILD=$(mktemp -d)
trap 'rm -rf "$BUILD"' EXIT
ARCH=$(uname -m)
TARGET="$ARCH-apple-macos11.0"
TOOLCHAIN=$(dirname "$(dirname "$(xcrun --find swiftc)")")
BACKDEPLOY="$TOOLCHAIN/lib/swift-5.5/macosx"

xcrun swiftc -target "$TARGET" -O -parse-as-library -module-name BigSurCompat -emit-library -static \
    -emit-module -emit-module-path "$BUILD/BigSurCompat.swiftmodule" -o "$BUILD/libBigSurCompat.a" \
    "$PACKAGE"/Sources/BigSurCompat/*.swift
xcrun swiftc -target "$TARGET" -parse-as-library -I "$BUILD" -L "$BUILD" -lBigSurCompat \
    -Xlinker -rpath -Xlinker "$BACKDEPLOY" -o "$BUILD/compat-checks" "$PACKAGE"/Sources/compat-checks/*.swift
echo "Built with $(xcrun swiftc --version 2>&1 | head -1) for $TARGET; running on macOS $(sw_vers -productVersion)."
"$BUILD/compat-checks" "$@"
