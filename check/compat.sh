#!/bin/bash
# Builds the port's compat runtimes (BigSurCompat, ObservationCompat without its macros, and the swift-subprocess
# stand-in) with whatever swiftc is installed and runs their checks. On the Big Sur Mac that is the Command Line Tools' Swift 5.5, whose SwiftPM won't
# build without XCTest (it ships with Xcode only), so this calls swiftc directly. The checks link the back-deployed
# Swift concurrency library from the toolchain, as the app's bundle carries it. Pass --display to also check
# CompatDisplayLink against the Mac's display.
#
#   check/compat.sh [--display]
set -euo pipefail
HERE=$(cd "$(dirname "$0")/.." && pwd)
PACKAGES="$HERE/add/Packages"
BUILD=$(mktemp -d)
trap 'rm -rf "$BUILD"' EXIT
TARGET="$(uname -m)-apple-macos11.0"
TOOLCHAIN=$(dirname "$(dirname "$(xcrun --find swiftc)")")
BACKDEPLOY="$TOOLCHAIN/lib/swift-5.5/macosx"

library() {
    local name=$1
    shift
    xcrun swiftc -target "$TARGET" -O -parse-as-library -module-name "$name" -emit-library -static \
        -emit-module -emit-module-path "$BUILD/$name.swiftmodule" -o "$BUILD/lib$name.a" "$@"
}

library_using() {
    local name=$1
    shift
    xcrun swiftc -target "$TARGET" -O -parse-as-library -module-name "$name" -emit-library -static -I "$BUILD" \
        -emit-module -emit-module-path "$BUILD/$name.swiftmodule" -o "$BUILD/lib$name.a" "$@"
}

checks() {
    local name=$1 modules=$2
    shift 2
    local links=()
    for module in $modules; do links+=(-l"$module"); done
    xcrun swiftc -target "$TARGET" -parse-as-library -I "$BUILD" -L "$BUILD" "${links[@]}" \
        -Xlinker -rpath -Xlinker "$BACKDEPLOY" -o "$BUILD/$name" "$@"
}

library BigSurCompat "$PACKAGES"/BigSurCompat/Sources/BigSurCompat/*.swift
checks compat-checks BigSurCompat "$PACKAGES"/BigSurCompat/Sources/compat-checks/*.swift
library ObservationCompat "$PACKAGES"/ObservationCompat/Sources/ObservationCompat/*.swift
checks observation-checks ObservationCompat "$PACKAGES"/ObservationCompat/Sources/observation-checks/*.swift
library_using Subprocess "$PACKAGES"/BigSur/swift-subprocess/Sources/Subprocess/*.swift
checks subprocess-checks "Subprocess BigSurCompat" "$PACKAGES"/BigSur/swift-subprocess/Sources/subprocess-checks/*.swift

echo "Built with $(xcrun swiftc --version 2>&1 | head -1) for $TARGET; running on macOS $(sw_vers -productVersion)."
status=0
echo "== BigSurCompat"
"$BUILD/compat-checks" "$@" || status=1
echo "== ObservationCompat"
"$BUILD/observation-checks" || status=1
echo "== Subprocess"
"$BUILD/subprocess-checks" || status=1
exit $status
