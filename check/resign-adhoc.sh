#!/bin/bash
# Signs a Light Touch bundle ad hoc as a whole: each Mach-O inside that has the hardened runtime is signed again
# without it, then the bundle. The vendor build signs its tools and libraries with the hardened runtime, for a release
# signed with a Developer ID. Signed ad hoc, the runtime's library validation refuses the bundle's own libraries, which
# have no Team ID: usbmuxd and inetcat die at launch ("mapped file has no Team ID and is not a platform binary"). The
# app's own binaries are already built without it (ENABLE_HARDENED_RUNTIME=NO). Entitlements and identifiers are kept.
#
#   check/resign-adhoc.sh APP
set -euo pipefail
APP=${1:?usage: check/resign-adhoc.sh APP}
HERE=$(cd "$(dirname "$0")" && pwd)
python3 -I "$HERE/machos.py" "$APP" | while IFS= read -r rel; do
    # Nothing in the loop may read its standard input, the list: codesign does. And no grep -q on codesign's output:
    # under pipefail, codesign dying of the closed pipe would read as no match.
    details=$(codesign -dv "$APP/$rel" < /dev/null 2>&1 || true)
    if printf '%s\n' "$details" | grep '^CodeDirectory' | grep -E 'flags=0x[0-9a-f]+\([^)]*runtime' > /dev/null; then
        codesign --force --sign - --preserve-metadata=identifier,entitlements "$APP/$rel" < /dev/null 2> /dev/null
        echo "resign-adhoc: $rel without the hardened runtime"
    fi
done
codesign --force --sign - --preserve-metadata=identifier,entitlements,flags "$APP" 2> /dev/null
codesign --verify --deep --strict "$APP"
