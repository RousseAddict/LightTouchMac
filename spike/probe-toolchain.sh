#!/bin/bash
# Phase 0 probe: can this runner's Xcode build Light Touch for macOS 11? It prints facts and never fails;
# probe.txt is the result.
set -u
SRC=${1:?usage: probe-toolchain.sh UPSTREAM_CHECKOUT}
OUT=${OUT:-spike-out}
mkdir -p "$OUT"
WORK=$(mktemp -d)

section() { printf '\n== %s\n' "$1"; }

{
    section host
    sw_vers
    uname -m
    sysctl -n hw.ncpu hw.memsize
    df -h / | tail -1

    section xcode
    xcode-select -p
    xcodebuild -version
    echo "TOOLCHAINS=${TOOLCHAINS:-default}"
    xcrun --find swiftc
    xcrun swift --version 2>&1
    SDK=$(xcrun --sdk macosx --show-sdk-path)
    echo "SDK: $SDK"

    section "SDK deployment targets"
    plutil -extract SupportedTargets.macosx.MinimumDeploymentTarget raw -o - "$SDK/SDKSettings.plist" 2>&1
    plutil -extract SupportedTargets.macosx.ValidDeploymentTargets json -o - "$SDK/SDKSettings.plist" 2>&1 | cut -c1-400

    section "back-deployed Swift concurrency"
    TOOLCHAIN=$(dirname "$(dirname "$(dirname "$(xcrun --find swiftc)")")")
    echo "toolchain: $TOOLCHAIN"
    ls "$TOOLCHAIN/usr/lib" | grep -i '^swift'
    ls -la "$TOOLCHAIN/usr/lib/swift-5.5/macosx" 2>&1

    section "async hello at x86_64-apple-macos11.0"
    cat > "$WORK/hello.swift" <<'EOF'
@main
struct Hello {
    static func main() async {
        try? await Task.sleep(nanoseconds: 1)
        print("ok")
    }
}
EOF
    if xcrun swiftc -swift-version 6 -parse-as-library -target x86_64-apple-macos11.0 "$WORK/hello.swift" \
        -o "$WORK/hello" 2>&1; then
        otool -L "$WORK/hello"
        otool -l "$WORK/hello" | grep -A4 LC_BUILD_VERSION | grep -E 'minos|sdk'
        otool -l "$WORK/hello" | grep -A2 LC_RPATH | grep path
    fi

    section "availability in this SDK"
    echo "-- NSLocking.withLock (every Foundation interface in the SDK)"
    find "$SDK/System/Library/Frameworks" "$SDK/usr/lib/swift" -path '*Foundation*' \
        -name 'arm64e-apple-macos.swiftinterface' 2>/dev/null | while read -r interface; do
        grep -n -B6 'func withLock' "$interface" | grep -E 'available|withLock|NSLocking|backDeployed|alwaysEmit' |
            sed "s|^|${interface#$SDK/}: |" | head -12
    done
    APPKIT="$SDK/System/Library/Frameworks/AppKit.framework/Headers"
    echo "-- NSSplitViewItem inspectorWithViewController"
    grep -n 'inspectorWithViewController' "$APPKIT/NSSplitViewItem.h"
    echo "-- NSView displayLinkWithTarget"
    grep -n 'displayLinkWithTarget' "$APPKIT/NSView.h"
    echo "-- CGWindowListCreateImage"
    grep -n -A3 'CGWindowListCreateImage(' "$SDK/System/Library/Frameworks/CoreGraphics.framework/Headers/CGWindow.h" | head -8
    echo "-- CVDisplayLinkCreateWithActiveCGDisplays"
    grep -n -A2 'CVDisplayLinkCreateWithActiveCGDisplays' "$SDK/System/Library/Frameworks/CoreVideo.framework/Headers/CVDisplayLink.h" | head -4

    section "project format"
    grep -m1 -E 'objectVersion' "$SRC/LightTouchMac.xcodeproj/project.pbxproj"
    grep -m1 -E 'LastUpgradeCheck' "$SRC/LightTouchMac.xcodeproj/project.pbxproj"
    xcodebuild -list -workspace "$SRC/LightTouchMac.xcworkspace" 2>&1 | head -30
} 2>&1 | tee "$OUT/probe.txt"
rm -rf "$WORK"
exit 0
