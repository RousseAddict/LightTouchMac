#!/bin/bash
# Checks a Light Touch bundle against this Mac's macOS (check/bundle.py says what fails and what is only reported).
#
#   check/bundle.sh APP [SYMBOLS]     SYMBOLS: the SF Symbol names the app uses, one per line
set -euo pipefail
APP=${1:?usage: check/bundle.sh APP [SYMBOLS]}
HERE=$(cd "$(dirname "$0")" && pwd)
TOOLS=$(mktemp -d)
trap 'rm -rf "$TOOLS"' EXIT
clang -O2 -o "$TOOLS/symcheck" "$HERE/symcheck.c"
clang -O2 -fobjc-arc -framework Foundation -o "$TOOLS/selcheck" "$HERE/selcheck.m"
clang -O2 -fobjc-arc -framework AppKit -o "$TOOLS/symbols" "$HERE/symbols.m"
python3 -I "$HERE/bundle.py" "$APP" "$TOOLS" ${2:+"$2"}
