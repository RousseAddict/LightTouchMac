#!/bin/bash
# Installs a swift.org Xcode toolchain (for example swift-6.4.1-RELEASE, Xcode 27's Swift) once its package
# signature checks out, and makes it the toolchain for the rest of the job through TOOLCHAINS in GITHUB_ENV.
# Upstream builds with Xcode 27, which GitHub's runners don't have; this pairs their newest Xcode with that compiler.
set -euo pipefail
NAME=${1:?usage: install-toolchain.sh swift-X.Y.Z-RELEASE}
VERSION=${NAME#swift-}
VERSION=${VERSION%-RELEASE}
URL="https://download.swift.org/swift-$VERSION-release/xcode/$NAME/$NAME-osx.pkg"
PKG="$RUNNER_TEMP/$NAME.pkg"

echo "Downloading $URL"
curl -fsSL -o "$PKG" "$URL"
pkgutil --check-signature "$PKG" | tee "$RUNNER_TEMP/$NAME-signature.txt"
grep -q 'Developer ID Installer:' "$RUNNER_TEMP/$NAME-signature.txt" ||
    { echo "::error::$NAME isn't signed with a Developer ID Installer certificate"; exit 1; }

sudo installer -pkg "$PKG" -target / > /dev/null
TOOLCHAIN="/Library/Developer/Toolchains/$NAME.xctoolchain"
ID=$(plutil -extract CFBundleIdentifier raw -o - "$TOOLCHAIN/Info.plist")
echo "TOOLCHAINS=$ID" >> "$GITHUB_ENV"
echo "Using $ID from $TOOLCHAIN"
TOOLCHAINS=$ID xcrun swift --version
