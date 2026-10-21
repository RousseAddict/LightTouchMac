# Prints the path, relative to the bundle, of every Mach-O file in it with an x86_64 slice, one per line.
import os, struct, sys

X86_64 = 0x01000007


def has_x86_64(path):
    try:
        with open(path, "rb") as f:
            head = f.read(4096)
    except OSError:
        return False
    if len(head) < 8:
        return False
    magic = struct.unpack(">I", head[:4])[0]
    if magic in (0xCAFEBABE, 0xCAFEBABF):  # fat; 0xCAFEBABE is also Java's class files, which have no such arch
        count = struct.unpack(">I", head[4:8])[0]
        size = 20 if magic == 0xCAFEBABE else 32
        return any(
            struct.unpack(">i", head[8 + i * size: 12 + i * size])[0] == X86_64
            for i in range(min(count, (len(head) - 8) // size))
        )
    if magic == 0xCFFAEDFE:  # thin 64-bit, little-endian
        return struct.unpack("<i", head[4:8])[0] == X86_64
    return False


bundle = sys.argv[1]
for root, dirs, files in os.walk(bundle):
    dirs.sort()
    for name in sorted(files):
        path = os.path.join(root, name)
        if not os.path.islink(path) and has_x86_64(path):
            print(os.path.relpath(path, bundle))
