#!/bin/bash
# Installs a Big Sur build of Light Touch on this Mac.
# 1. The build: the Package workflow's artifact (the zip GitHub gives you, the zip inside it, or the folder a browser
#    unpacks it to). It holds Light Touch.app, bigsur-build.json (the upstream release it was built from) and
#    bigsur-symbols.txt.
# 2. That official release: downloaded (or --official ZIP), checked against the release's SHA256SUMS and GitHub's
#    digest of the asset, and its app's signature verified: Developer ID SM75355Y6R, notarized. The signature seals
#    the app's resources, so what step 3 copies is what the developer shipped.
# 3. The official app's Guest, Device, licenses, usbmuxd-conf and build-inputs.json go into the Big Sur app: the
#    guest payload and the built-in iPod, the same on any macOS, which the port doesn't redistribute.
# 4. The Big Sur app is signed ad hoc again (its seal now covers those resources), and check/bundle.sh checks it
#    against this Mac: system symbols, minimum versions, bundled libraries, SF Symbols, signature.
# 5. It loses the quarantine flag and goes to DIRECTORY (default /Applications). An app already there is moved to
#    the Trash only with --replace.
#
# The first time a new build runs, macOS may block it without a word: System Preferences, Security & Privacy, General,
# then Open Anyway.
#
#   install.sh BUILD [--to DIRECTORY] [--replace] [--official ZIP]     BUILD: the artifact's zip or its folder
set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
REPO=samhenrigold/LightTouchMac
ASSET=LightTouchMac-universal.zip
TEAM=SM75355Y6R  # Sam Gold's Developer ID, which signs and notarizes the official releases
BUNDLE_ID=gold.samhenri.LightTouchMac
RESOURCES="Guest Device licenses usbmuxd-conf build-inputs.json"

BUILD="" DEST=/Applications REPLACE=0 OFFICIAL=""
while [ $# -gt 0 ]; do
    case "$1" in
        --to) DEST=${2:?--to needs a directory}; shift 2 ;;
        --replace) REPLACE=1; shift ;;
        --official) OFFICIAL=${2:?--official needs a zip}; shift 2 ;;
        -*) echo "usage: install.sh BUILD [--to DIRECTORY] [--replace] [--official ZIP]" >&2; exit 2 ;;
        *) [ -z "$BUILD" ] || { echo "install: one build at a time" >&2; exit 2; }; BUILD=$1; shift ;;
    esac
done
[ -n "$BUILD" ] || { echo "usage: install.sh BUILD [--to DIRECTORY] [--replace] [--official ZIP]" >&2; exit 2; }
[ -d "$DEST" ] || { echo "install: no directory $DEST" >&2; exit 1; }
if [ "$REPLACE" = 1 ] && pgrep -f "$DEST/Light Touch.app/Contents/MacOS/" > /dev/null; then
    echo "install: $DEST/Light Touch.app is running; quit it (its devices stop with it), then run install.sh again" >&2
    exit 1
fi
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

# 1. The build. GitHub zips an artifact, so the port's own zip may be inside the one downloaded; a browser may have
# unpacked both.
mkdir "$WORK/build"
if [ -d "$BUILD" ]; then
    ditto --noextattr "$BUILD" "$WORK/build"
else
    ditto -x -k "$BUILD" "$WORK/build"
fi
INNER=$(find "$WORK/build" -maxdepth 1 -name '*.zip' | head -1)
if [ ! -d "$WORK/build/Light Touch.app" ] && [ -n "$INNER" ]; then
    mkdir "$WORK/build/inner"
    ditto -x -k "$INNER" "$WORK/build/inner"
    BUILT="$WORK/build/inner"
else
    BUILT="$WORK/build"
fi
APP="$BUILT/Light Touch.app"
[ -d "$APP" ] || { echo "install: $BUILD holds no Light Touch.app" >&2; exit 1; }
TAG=$(python3 -I -c 'import json, sys; print(json.load(open(sys.argv[1]))["upstream_tag"])' "$BUILT/bigsur-build.json")
echo "install: a Big Sur build of Light Touch $TAG"

# 2. The official release of that tag.
if [ -z "$OFFICIAL" ]; then
    OFFICIAL="$WORK/$ASSET"
    echo "install: downloading $REPO $TAG ($ASSET, about 400 MB)"
    curl -fL --proto '=https' --progress-bar -o "$OFFICIAL" "https://github.com/$REPO/releases/download/$TAG/$ASSET"
fi
curl -fsSL --proto '=https' -o "$WORK/SHA256SUMS" "https://github.com/$REPO/releases/download/$TAG/SHA256SUMS"
curl -fsSL --proto '=https' -o "$WORK/release.json" "https://api.github.com/repos/$REPO/releases/tags/$TAG"
SUM=$(shasum -a 256 "$OFFICIAL" | awk '{print $1}')
grep -qx "$SUM  $ASSET" "$WORK/SHA256SUMS" || { echo "install: $OFFICIAL isn't $TAG's $ASSET (SHA256SUMS)" >&2; exit 1; }
DIGEST=$(python3 -I -c '
import json, sys
release = json.load(open(sys.argv[1]))
print(next((a.get("digest") or "" for a in release.get("assets", []) if a["name"] == sys.argv[2]), ""))
' "$WORK/release.json" "$ASSET")
[ "$DIGEST" = "sha256:$SUM" ] || { echo "install: $OFFICIAL isn't $TAG's $ASSET (GitHub digest $DIGEST)" >&2; exit 1; }
mkdir "$WORK/official"
ditto -x -k "$OFFICIAL" "$WORK/official"
UPSTREAM="$WORK/official/Light Touch.app"
codesign --verify --deep --strict "$UPSTREAM" || { echo "install: the official app's signature doesn't verify" >&2; exit 1; }
codesign -dv --verbose=2 "$UPSTREAM" 2> "$WORK/signature"
grep -qx "TeamIdentifier=$TEAM" "$WORK/signature" && grep -qx "Identifier=$BUNDLE_ID" "$WORK/signature" \
    || { echo "install: the official app isn't $BUNDLE_ID signed by team $TEAM" >&2; cat "$WORK/signature" >&2; exit 1; }
spctl --assess --type execute "$UPSTREAM" || { echo "install: Gatekeeper rejects the official app" >&2; exit 1; }
echo "install: $ASSET checks out: SHA256SUMS, GitHub's digest, Developer ID $TEAM, notarized"

# 3. Its resources into the Big Sur app.
for name in $RESOURCES; do
    [ -e "$UPSTREAM/Contents/Resources/$name" ] || { echo "install: the official app has no Resources/$name" >&2; exit 1; }
    rm -rf "$APP/Contents/Resources/$name"
    ditto "$UPSTREAM/Contents/Resources/$name" "$APP/Contents/Resources/$name"
done

# 4. Signed again, and checked against this Mac.
codesign --force --sign - --preserve-metadata=identifier,entitlements,flags "$APP"
"$HERE/check/bundle.sh" "$APP" "$BUILT/bigsur-symbols.txt"

# 5. Installed.
xattr -dr com.apple.quarantine "$APP" 2>/dev/null || true
TARGET="$DEST/Light Touch.app"
if [ -e "$TARGET" ]; then
    [ "$REPLACE" = 1 ] || { echo "install: $TARGET exists; --replace moves it to the Trash first" >&2; exit 1; }
    # Not while it runs: its devices' helpers run from inside it.
    if pgrep -f "$TARGET/Contents/MacOS/" > /dev/null; then
        echo "install: $TARGET is running; quit it (its devices stop with it), then run install.sh again" >&2
        exit 1
    fi
    mv "$TARGET" "$HOME/.Trash/Light Touch $(date +%Y-%m-%d-%H%M%S).app"
    echo "install: the old $TARGET is in the Trash"
fi
ditto "$APP" "$TARGET"
echo "install: installed $TARGET"
