# Prints "name\tkind" for each string literal in the shipped Swift code that could be an SF Symbol name (lowercase
# words and digits, dot-separated). The kind is "strong" for a dotted name or one passed as a symbol (systemName:,
# systemSymbolName:, systemImage:, symbol:, fallbackSymbol:), else "weak": a lone word may be any string. The package
# job keeps the names its macOS draws (symbols --present) as bigsur-symbols.txt; check/bundle.sh fails on a strong
# one the Big Sur Mac can't draw and reports a weak one.
#
#   python3 -I symbol-candidates.py CHECKOUT
import os, re, sys

ROOTS = ["LightTouchMac", "LightTouchDevice", "LightTouchServices", "Packages/LightTouchCore/Sources",
         "Packages/HostRuntime/Sources", "Packages/DeviceServices/Sources", "Packages/FirmwareKit/Sources"]
literal = re.compile(r'(\b(?:systemName|systemSymbolName|systemImage|symbol|fallbackSymbol):\s*)?"([a-z0-9]+(?:\.[a-z0-9]+)*)"')
kinds = {}
for root in ROOTS:
    for directory, _, files in os.walk(os.path.join(sys.argv[1], root)):
        for name in files:
            if name.endswith(".swift"):
                for label, value in literal.findall(open(os.path.join(directory, name), encoding="utf-8").read()):
                    if label or "." in value or kinds.get(value) == "strong":
                        kinds[value] = "strong"
                    else:
                        kinds.setdefault(value, "weak")
for value in sorted(kinds):
    print(f"{value}\t{kinds[value]}")
