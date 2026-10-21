# Prints "binary\tlibpath\tsymbol\tweak" for every undefined symbol of each x86_64 Mach-O listed (paths relative
# to the bundle, one per line, as machos.py prints them).
import re, subprocess, sys, os

app, listing = sys.argv[1], sys.argv[2]
for line in open(listing):
    rel = line.rstrip("\n")
    path = os.path.join(app, rel)
    libs = {}
    for l in subprocess.run(["otool", "-arch", "x86_64", "-L", path], capture_output=True, text=True).stdout.splitlines()[1:]:
        p = l.strip().split(" (")[0]
        base = os.path.basename(p)
        short = base[: -len(".dylib")] if base.endswith(".dylib") else base
        short = short.split(".")[0]
        libs.setdefault(short, p)
    out = subprocess.run(["nm", "-arch", "x86_64", "-m", "-u", path], capture_output=True, text=True).stdout
    for l in out.splitlines():
        m = re.match(r"\s*\(undefined\) (weak )?external (\S+) \(from (\S+)\)", l)
        if not m:
            continue
        weak, sym, short = m.groups()
        print(f"{rel}\t{libs.get(short, '?' + short)}\t{sym}\t{'weak' if weak else 'strong'}")
