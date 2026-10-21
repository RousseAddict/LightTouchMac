# Prints the selector names an x86_64 Mach-O references (its __objc_selrefs), decoding chained-fixup rebases.
import struct, sys

def slice_offset(data):
    magic = struct.unpack(">I", data[:4])[0]
    if magic in (0xCAFEBABE,):
        n = struct.unpack(">I", data[4:8])[0]
        for i in range(n):
            cputype, _, off, size, _ = struct.unpack(">iiIII", data[8 + i * 20: 28 + i * 20])
            if cputype == 0x01000007:
                return off
        raise SystemExit("no x86_64 slice")
    return 0

data = open(sys.argv[1], "rb").read()
base = slice_offset(data)
ncmds = struct.unpack("<I", data[base + 16: base + 20])[0]
p = base + 32
sections, text_vmaddr = {}, None
for _ in range(ncmds):
    cmd, size = struct.unpack("<II", data[p: p + 8])
    if cmd == 0x19:  # LC_SEGMENT_64
        segname = data[p + 8: p + 24].rstrip(b"\0").decode()
        vmaddr, vmsize, fileoff = struct.unpack("<QQQ", data[p + 24: p + 48])
        if segname == "__TEXT":
            text_vmaddr = vmaddr
        nsects = struct.unpack("<I", data[p + 64: p + 68])[0]
        for s in range(nsects):
            q = p + 72 + s * 80
            sect = data[q: q + 16].rstrip(b"\0").decode()
            addr, sz, off = struct.unpack("<QQI", data[q + 32: q + 52])
            sections[sect] = (addr, sz, off)
    p += size
if "__objc_selrefs" not in sections:
    raise SystemExit(0)  # sends no Objective-C messages
ref_addr, ref_size, ref_off = sections["__objc_selrefs"]
mn_addr, mn_size, mn_off = sections["__objc_methname"]
for i in range(ref_size // 8):
    v = struct.unpack("<Q", data[base + ref_off + i * 8: base + ref_off + i * 8 + 8])[0]
    target = v & 0xFFFFFFFFF
    if target < text_vmaddr:
        target += text_vmaddr  # DYLD_CHAINED_PTR_64_OFFSET: an offset from the image base
    o = base + mn_off + (target - mn_addr)
    print(data[o: data.index(b"\0", o)].decode())
