#!/bin/bash
# Phase 0: compile upstream's LightTouchMac scheme (Debug, the runner's architecture, unsigned) with optional extra
# build settings, then summarize the errors by module and by API. Availability errors don't depend on the
# architecture, so the runner's own, with Homebrew's libimobiledevice and a stub vendor directory, is enough. A
# project in a format this Xcode can't open is retried once with objectVersion lowered, and the summary says so. It
# never fails the job; the summary is the result.
#
#   compile.sh UPSTREAM_CHECKOUT NAME [SETTING=VALUE ...]
set -u
SRC=${1:?usage: compile.sh UPSTREAM_CHECKOUT NAME [SETTING=VALUE ...]}
NAME=${2:?missing NAME}
shift 2
HERE=$(cd "$(dirname "$0")" && pwd)
OUT=${OUT:-spike-out}
TMP=${RUNNER_TEMP:-/tmp}
mkdir -p "$OUT"

# From v1.0-2026.10.21 the build's first phase (scripts/vendor-check) wants VENDOR_DIR named by the vendor pin key and
# holding a vendor.json.
KEY=stub
[ ! -f "$SRC/scripts/vendor-check" ] || KEY=$(bash "$SRC/scripts/vendor-check" --key)
STUB="$TMP/vendor-stub/$KEY"
mkdir -p "$STUB/Resources/Guest" "$STUB/Frameworks" "$STUB/include"
touch "$STUB/vendor.json"
printf 'VENDOR_DIR = %s\n' "$STUB" > "$SRC/Configuration/Local.xcconfig"

build() {
    xcodebuild -workspace "$SRC/LightTouchMac.xcworkspace" -scheme LightTouchMac -configuration Debug \
        -destination 'generic/platform=macOS' -derivedDataPath "$TMP/dd-$NAME" \
        -skipMacroValidation -skipPackagePluginValidation \
        ARCHS="$(uname -m)" ONLY_ACTIVE_ARCH=NO CODE_SIGNING_ALLOWED=NO "$@" build > "$OUT/$NAME.log" 2>&1
}

start=$(date +%s)
build "$@"
status=$?
note=""
if grep -q 'future Xcode project file format' "$OUT/$NAME.log"; then
    version=$(grep -m1 -oE 'objectVersion = [0-9]+' "$SRC/LightTouchMac.xcodeproj/project.pbxproj")
    sed -i '' -E 's/objectVersion = [0-9]+;/objectVersion = 77;/' "$SRC/LightTouchMac.xcodeproj/project.pbxproj"
    note="Retried with objectVersion lowered from ${version#objectVersion = } to 77."
    build "$@"
    status=$?
fi
seconds=$(($(date +%s) - start))

python3 -I "$HERE/summarize.py" "$OUT/$NAME.log" "$SRC" "$NAME" "$status" "$seconds" "$note" "$*" \
    > "$OUT/summary-$NAME.md"
cat "$OUT/summary-$NAME.md"
exit 0
