# Checks a Light Touch bundle against the macOS it runs on, as the port's analysis checked the release; install.sh
# runs it (through bundle.sh, which builds the tools) after it grafts the resources in. Failures:
# - a minimum macOS above this one: the app's LSMinimumSystemVersion, or any x86_64 Mach-O's minos;
# - a symbol a Mach-O imports strongly from a system library that this system's library lacks (dyld stops on it);
# - an @rpath, @loader_path or @executable_path library a Mach-O loads that isn't in the bundle;
# - an SF Symbol the app names (SYMBOLS, one per line) that this system can't draw;
# - a code signature that doesn't verify.
# Reported only: weak imports this system lacks, and the Objective-C selectors a binary sends that neither the
# bundle nor this system implements (optional delegate methods, and methods added lazily, such as NSView's
# safeAreaRect, show up there).
#
#   python3 -I bundle.py APP TOOLS_DIR [SYMBOLS]
import os, plistlib, re, subprocess, sys

app, tools = sys.argv[1], sys.argv[2]
symbols_file = sys.argv[3] if len(sys.argv) > 3 else ""
here = os.path.dirname(os.path.abspath(__file__))


def run(args, stdin=None):
    return subprocess.run(args, input=stdin, capture_output=True, text=True, check=True).stdout


def version(text):
    return tuple(int(part) for part in text.split("."))


os_version = run(["sw_vers", "-productVersion"]).strip()
machos = run([sys.executable, "-I", os.path.join(here, "machos.py"), app]).splitlines()
problems, notes = [], []
print(f"== {len(machos)} Mach-O files with an x86_64 slice, on macOS {os_version}")

# Minimum macOS.
minimum = plistlib.load(open(os.path.join(app, "Contents/Info.plist"), "rb")).get("LSMinimumSystemVersion")
if minimum and version(minimum) > version(os_version):
    problems.append(f"Info.plist: LSMinimumSystemVersion {minimum}")
build_version = re.compile(r"cmd LC_BUILD_VERSION\n\s*cmdsize \d+\n\s*platform (\d+)\n\s*minos (\S+)")
version_min = re.compile(r"cmd LC_VERSION_MIN_MACOSX\n\s*cmdsize \d+\n\s*version (\S+)")
for rel in machos:
    load = run(["otool", "-arch", "x86_64", "-l", os.path.join(app, rel)])
    found = build_version.search(load)
    minos = found.group(2) if found else (version_min.search(load) or [None, None])[1]
    if found and found.group(1) != "1":
        problems.append(f"{rel}: built for platform {found.group(1)}, not macOS")
    elif minos and version(minos) > version(os_version):
        problems.append(f"{rel}: minos {minos}")

# Libraries the bundle carries.
names = {name for _, _, files in os.walk(app) for name in files}
for rel in machos:
    for line in run(["otool", "-arch", "x86_64", "-L", os.path.join(app, rel)]).splitlines()[1:]:
        library = line.strip().split(" (")[0]
        if library.startswith("@") and os.path.basename(library) not in names:
            problems.append(f"{rel}: loads {library}, which isn't in the bundle")

# System symbols.
listing = os.path.join(tools, "machos.txt")
open(listing, "w").write("\n".join(machos) + "\n")
imports = run([sys.executable, "-I", os.path.join(here, "imports.py"), app, listing])
weak_missing = 0
for line in run([os.path.join(tools, "symcheck")], stdin=imports).splitlines():
    status, binary, library, symbol, strength = line.split("\t")
    if status == "ok":
        continue
    if strength == "strong":
        problems.append(f"{binary}: {symbol} from {library} ({status})")
    else:
        weak_missing += 1
if weak_missing:
    notes.append(f"{weak_missing} weak imports this system lacks (code guards those with availability checks)")

# Selectors.
own = set()
for rel in machos:
    for line in run(["otool", "-arch", "x86_64", "-oV", os.path.join(app, rel)]).splitlines():
        fields = line.split()
        if len(fields) >= 3 and fields[0] == "name":
            own.add(fields[2])
for rel in machos:
    path = os.path.join(app, rel)
    sent = set(run([sys.executable, "-I", os.path.join(here, "selrefs.py"), path]).split()) - own
    if not sent:
        continue
    libraries = [
        line.strip().split(" (")[0]
        for line in run(["otool", "-arch", "x86_64", "-L", path]).splitlines()[1:]
        if line.strip().startswith(("/System/", "/usr/lib/"))
    ]
    missing = run([os.path.join(tools, "selcheck")] + libraries, stdin="\n".join(sorted(sent)) + "\n").split()
    if missing:
        notes.append(f"{rel}: sends {len(missing)} selectors nothing here implements: {' '.join(missing)}")

# SF Symbols.
if symbols_file:
    wanted = open(symbols_file).read()
    for name in run([os.path.join(tools, "symbols")], stdin=wanted).split():
        problems.append(f"SF Symbol {name} doesn't exist on this system")
    print(f"== {len(wanted.split())} SF Symbols named")

# Signature.
signature = subprocess.run(["codesign", "--verify", "--deep", "--strict", app], capture_output=True, text=True)
if signature.returncode != 0:
    problems.append("code signature: " + signature.stderr.strip().replace("\n", "; "))

for note in notes:
    print("note  " + note)
for problem in problems:
    print("FAIL  " + problem)
print(f"== {len(problems)} problems" if problems else "== The bundle checks out on this Mac.")
sys.exit(1 if problems else 0)
