# Checks a Light Touch bundle against the macOS it runs on, as the port's analysis checked the release; install.sh
# runs it (through bundle.sh, which builds the tools) after it grafts the resources in. Failures:
# - a minimum macOS above this one: the app's LSMinimumSystemVersion, or any x86_64 Mach-O's minos;
# - a symbol a Mach-O imports strongly from a system library that this system's library lacks (dyld stops on it);
# - an @rpath, @loader_path or @executable_path library a Mach-O loads that neither the bundle nor this system has;
# - an SF Symbol the app names (SYMBOLS, from symbol-candidates.py) that this system can't draw;
# - a code signature that doesn't verify, or ad-hoc code whose hardened runtime refuses the bundle's own libraries.
# Reported only: weak imports this system lacks, and the Objective-C selectors a binary sends that neither the
# bundle nor this system implements (optional delegate methods, and methods added lazily, such as NSView's
# safeAreaRect, show up there).
#
#   python3 -I bundle.py APP TOOLS_DIR [SYMBOLS]
import ctypes, os, plistlib, re, subprocess, sys

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
    # A zippered library (the back-deployed Swift concurrency one) has a record per platform. macOS's is platform 1, or
    # the older LC_VERSION_MIN_MACOSX.
    platforms = dict(build_version.findall(load))
    old = version_min.search(load)
    minos = platforms.get("1") or (old.group(1) if old else None)
    if platforms and not minos:
        problems.append(f"{rel}: built for platform {', '.join(platforms)}, not macOS")
    elif minos and version(minos) > version(os_version):
        problems.append(f"{rel}: minos {minos}")

# Libraries the bundle carries, or this system does (an @rpath can be /usr/lib/swift, whose libraries are in the
# shared cache rather than on disk, so those are tried with dlopen).
def loadable(path):
    if os.path.exists(path):
        return True
    if path.startswith(("/usr/lib/", "/System/")):
        try:
            ctypes.CDLL(path)
            return True
        except OSError:
            return False
    return False


executable_dir = os.path.join(app, "Contents/MacOS")
rpath = re.compile(r"cmd LC_RPATH\n\s*cmdsize \d+\n\s*path (\S+)")
# A library without rpaths of its own resolves @rpath through the executable that loads it: take every executable's.
executable_rpaths = [
    r.replace("@loader_path", executable_dir).replace("@executable_path", executable_dir)
    for rel in machos if rel.startswith("Contents/MacOS/")
    for r in rpath.findall(run(["otool", "-arch", "x86_64", "-l", os.path.join(app, rel)]))
]
for rel in machos:
    path = os.path.join(app, rel)
    load = run(["otool", "-arch", "x86_64", "-l", path])
    rpaths = rpath.findall(load) + executable_rpaths
    own = run(["otool", "-arch", "x86_64", "-D", path]).splitlines()[1:]  # a library's own install name

    def expand(text):
        return text.replace("@loader_path", os.path.dirname(path)).replace("@executable_path", executable_dir)

    for line in run(["otool", "-arch", "x86_64", "-L", path]).splitlines()[1:]:
        library = line.strip().split(" (")[0]
        if library in own:
            continue
        if library.startswith("@rpath/"):
            rest = library[len("@rpath/"):]
            found = any(loadable(os.path.join(expand(r), rest)) for r in rpaths)
        elif library.startswith("@"):
            found = loadable(expand(library))
        else:
            continue
        if not found:
            problems.append(f"{rel}: loads {library}, which neither the bundle nor this system has")

# Ad-hoc code with the hardened runtime: its library validation refuses the bundle's own libraries, which have no
# Team ID, so dyld stops it at launch (check/resign-adhoc.sh signs such code again without the runtime).
for rel in machos:
    path = os.path.join(app, rel)
    details = subprocess.run(["codesign", "-dv", path], capture_output=True, text=True).stderr
    found = re.search(r"^CodeDirectory .*flags=0x[0-9a-f]+\(([^)]*)\)", details, re.M)
    flags = found.group(1).split(",") if found else []
    if "runtime" not in flags or "adhoc" not in flags:
        continue
    # Library validation is the loading process's: only an executable's flags count.
    if " EXECUTE " not in run(["otool", "-arch", "x86_64", "-hv", path]):
        continue
    own = run(["otool", "-arch", "x86_64", "-D", path]).splitlines()[1:]
    loads = [line.strip().split(" (")[0] for line in run(["otool", "-arch", "x86_64", "-L", path]).splitlines()[1:]]
    if not any(library.startswith("@") and library not in own for library in loads):
        continue
    entitlements = subprocess.run(["codesign", "-d", "--entitlements", ":-", path], capture_output=True, text=True).stdout
    if "com.apple.security.cs.disable-library-validation" not in entitlements:
        problems.append(f"{rel}: signed ad hoc with the hardened runtime, which refuses the bundle's own libraries")

# System symbols.
listing = os.path.join(tools, "machos.txt")
open(listing, "w").write("\n".join(machos) + "\n")
imports = run([sys.executable, "-I", os.path.join(here, "imports.py"), app, listing])
weak_missing = 0
for line in run([os.path.join(tools, "symcheck")], stdin=imports).splitlines():
    status, binary, library, symbol, strength = line.split("\t")
    # dyld_stub_binder is dyld's own, which dlsym never finds.
    if status == "ok" or symbol == "dyld_stub_binder":
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

# SF Symbols: "name" or "name\tkind" lines (symbol-candidates.py); a weak name may not be a symbol at all.
if symbols_file:
    kinds = dict((line.split("\t") + ["strong"])[:2] for line in open(symbols_file).read().splitlines() if line)
    missing = run([os.path.join(tools, "symbols")], stdin="\n".join(kinds) + "\n").split()
    for name in missing:
        if kinds[name] == "strong":
            problems.append(f"SF Symbol {name} doesn't exist on this system")
    weak = [name for name in missing if kinds[name] != "strong"]
    if weak:
        notes.append(f"{len(weak)} words the app uses are SF Symbols on the build's macOS but not here: {' '.join(weak)}")
    print(f"== {len(kinds)} SF Symbol names")

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
