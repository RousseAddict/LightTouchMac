// The iPod touch 2G's NAND as an image store (record format 2), which qemu-ios's FMSS writes in place
// (hw/arm/nand-image.c): geometry.json and cs0.pages ... cs3.pages, the record of page p of a chip select at
// p * 4160, data then spare, stored XOR the generated layout's blank record (zero data, spare bytes 8 and 10 0xFF:
// ipod_touch_fmss.c fmss_blank_page), so a hole reads as the blank page. The layout is unchanged: pages sit where
// N72NAND's generated layout puts them, and the guest's writes at their logical homes.
//
// Format 1 is the page directory (cs<N>/<page>.page) under an overlay of the same layout; LegacyReader reads it as the
// FMSS served it, and convert and verify are the halves of its migration (K48NANDMigration).
//
//   let store = try N72NANDImage.Store(create: dir)          // geometry.json and four sparse chip files
//   try store.write(page, record); try store.sync()
//   let reader = try N72NANDImage.reader(base: nand, overlay: overlay)   // either format, as the guest reads it

import Darwin
import Foundation

public enum N72NANDImage {
    public static let format = "nand-xor-blank-v2", blank = "n72-generated"
    static let chips = 4, blocksPerChip = 4096
    static let stride = N72NAND.page + N72NAND.spare
    static let blockBytes = N72NAND.pagesPerBlock * stride
    static let chipBytes = blocksPerChip * blockBytes
    static let pagesPerChip = blocksPerChip * N72NAND.pagesPerBlock
    /// What a hole reads as, and the XOR key of every stored record.
    static let blankRecord = [UInt8](repeating: 0, count: N72NAND.page) + N72NAND.blankSpare

    static func name(_ cs: Int) -> String { "cs\(cs).pages" }

    static func geometry() throws -> Data {
        let g: [String: Any] = [
            "storage_format": format, "blank": blank, "board": "n72ap", "layout": "n72-generated-v1",
            "chip_selects": chips, "page_bytes": N72NAND.page, "spare_bytes": N72NAND.spare,
            "pages_per_block": N72NAND.pagesPerBlock, "blocks_per_ce": blocksPerChip,
        ]
        return try JSONSerialization.data(withJSONObject: g, options: [.sortedKeys, .prettyPrinted])
    }

    /// Whether `nand` is an n72 image store.
    public static func isImage(_ nand: URL) -> Bool {
        let g = (try? Data(contentsOf: nand.appendingPathComponent("geometry.json")))
            .flatMap { try? JSONSerialization.jsonObject(with: $0) as? [String: Any] }
        return g?["storage_format"] as? String == format && g?["blank"] as? String == blank
    }

    /// One store's chip files, open.
    final class Store: @unchecked Sendable {  // pread and pwrite at distinct offsets
        let fds: [Int32]
        let url: URL

        /// `dir` (created, with its geometry and sized empty chip files) open for writing.
        convenience init(create dir: URL) throws {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: false)
            try N72NANDImage.geometry().write(to: dir.appendingPathComponent("geometry.json"))
            try self.init(dir, writable: true, create: true)
        }

        init(_ dir: URL, writable: Bool = false, create: Bool = false) throws {
            guard N72NANDImage.isImage(dir) else {
                throw FirmwareError(.unsupported, "\(dir.path): not an n72 image store")
            }
            url = dir
            var fds: [Int32] = []
            for cs in 0..<N72NANDImage.chips {
                let path = dir.appendingPathComponent(N72NANDImage.name(cs)).path
                let fd = Darwin.open(path, writable ? O_RDWR | (create ? O_CREAT | O_EXCL : 0) : O_RDONLY, 0o644)
                var st = stat()
                guard fd >= 0, !create || ftruncate(fd, off_t(N72NANDImage.chipBytes)) == 0, fstat(fd, &st) == 0
                else {
                    let why = String(cString: strerror(errno))
                    if fd >= 0 { Darwin.close(fd) }
                    fds.forEach { Darwin.close($0) }
                    throw FirmwareError(.internal, "\(path): \(why)")
                }
                fds.append(fd)
                guard Int(st.st_size) == N72NANDImage.chipBytes else {
                    fds.forEach { Darwin.close($0) }
                    throw FirmwareError(.unsupported, "\(path): NAND file size differs from geometry")
                }
            }
            self.fds = fds
        }

        deinit { fds.forEach { Darwin.close($0) } }

        /// The page's record as the FMSS reads it.
        func read(_ p: N72NAND.Page) throws -> [UInt8] {
            var record = [UInt8](repeating: 0, count: N72NANDImage.stride)
            try K48NANDImage.read(fds[p.cs], &record, at: p.page * N72NANDImage.stride)
            N72NANDImage.xor(&record, 0)
            return record
        }

        /// The `count` records of `p`'s erase block, raw (stored, not yet XOR the blank).
        func readBlock(cs: Int, block: Int, into buffer: inout [UInt8]) throws {
            try K48NANDImage.read(fds[cs], &buffer, at: block * N72NANDImage.blockBytes)
        }

        func write(_ p: N72NAND.Page, _ record: [UInt8]) throws {
            var stored = record
            N72NANDImage.xor(&stored, 0)
            try K48NANDImage.write(fds[p.cs], stored[...], at: p.page * N72NANDImage.stride)
        }

        func sync() throws {
            for fd in fds where fsync(fd) != 0 {
                throw FirmwareError(.internal, "\(url.path): \(String(cString: strerror(errno)))")
            }
        }

        /// Erase blocks of chip `cs` holding data (SEEK_DATA; APFS zero-fills holes under 16 MiB, which read blank).
        func dataBlocks(_ cs: Int) -> Set<Int> { K48NANDImage.dataBlocks(fds[cs], blockBytes: N72NANDImage.blockBytes) }
    }

    /// Records in `buffer` (from `offset`, a whole number of them) XOR the blank record: stored to read, or back.
    static func xor(_ buffer: inout [UInt8], _ offset: Int) {
        buffer.withUnsafeMutableBytes { raw in
            for r in Swift.stride(from: offset, to: raw.count, by: stride) {
                raw[r + N72NAND.page + 8] ^= 0xFF
                raw[r + N72NAND.page + 10] ^= 0xFF
            }
        }
    }

    // MARK: Format 1

    /// The page directory under its overlay, as the FMSS read it (its default, generated mode): a page from the
    /// overlay's file when there is one, else blank when the overlay marks its block erased (blk<B>.erased, only ever
    /// written under FMSS_ERASE, as VolumeRebuild has always honored them), else the base's file, else blank. A short
    /// file reads zero-filled.
    struct LegacyReader {
        let base: URL
        let overlay: URL?
        let baseNames: [Set<String>]
        let overlayNames: [Set<String>]

        init(base: URL, overlay: URL?) {
            let fm = FileManager.default
            func names(_ d: URL?, _ cs: Int) -> Set<String> {
                guard let d else { return [] }
                return Set((try? fm.contentsOfDirectory(atPath: d.appendingPathComponent("cs\(cs)").path)) ?? [])
            }
            self.base = base
            self.overlay = overlay
            baseNames = (0..<4).map { names(base, $0) }
            overlayNames = (0..<4).map { names(overlay, $0) }
        }

        /// Every page some file names (in the base or the overlay), and every page of a marked block.
        var pages: Set<N72NAND.Page> {
            var out = Set<N72NAND.Page>()
            for cs in 0..<4 {
                for name in baseNames[cs].union(overlayNames[cs]) {
                    if let page = Self.page(name) { out.insert(N72NAND.Page(cs: cs, page: page)) }
                    if let block = Self.erased(name), overlayNames[cs].contains(name) {
                        for p in block * N72NAND.pagesPerBlock..<(block + 1) * N72NAND.pagesPerBlock {
                            out.insert(N72NAND.Page(cs: cs, page: p))
                        }
                    }
                }
            }
            return out
        }

        static func page(_ name: String) -> Int? {
            guard name.hasSuffix(".page"), !name.hasPrefix(".") else { return nil }
            return Int(name.dropLast(5))
        }

        static func erased(_ name: String) -> Int? {
            guard name.hasPrefix("blk"), name.hasSuffix(".erased") else { return nil }
            return Int(name.dropFirst(3).dropLast(7))
        }

        func file(_ p: N72NAND.Page) -> URL? {
            let name = "\(p.page).page"
            if let overlay, overlayNames[p.cs].contains(name) {
                return overlay.appendingPathComponent("cs\(p.cs)/\(name)")
            }
            if overlayNames[p.cs].contains("blk\(p.page / N72NAND.pagesPerBlock).erased") { return nil }
            return baseNames[p.cs].contains(name) ? base.appendingPathComponent("cs\(p.cs)/\(name)") : nil
        }

        /// The page's record (data and spare) as the guest read it.
        func read(_ p: N72NAND.Page) throws -> [UInt8] {
            guard let url = file(p) else { return N72NANDImage.blankRecord }
            var record = [UInt8](repeating: 0, count: N72NANDImage.stride)
            let fd = Darwin.open(url.path, O_RDONLY)
            guard fd >= 0 else { throw FirmwareError(.internal, "\(url.path): \(String(cString: strerror(errno)))") }
            defer { Darwin.close(fd) }
            let got = record.withUnsafeMutableBytes { pread(fd, $0.baseAddress, $0.count, 0) }
            guard got >= 0 else { throw FirmwareError(.internal, "\(url.path): \(String(cString: strerror(errno)))") }
            return record
        }
    }

    /// A store of either format read as the guest reads it: an image's live clone (`overlay/nand`) when there is
    /// one, else the image alone; a page directory under `overlay`.
    static func reader(base: URL, overlay: URL?) throws -> @Sendable (N72NAND.Page) throws -> [UInt8] {
        if isImage(base) {
            let live = overlay?.appendingPathComponent("nand")
            let store = try Store(live.map { isImage($0) ? $0 : base } ?? base)
            // a page in no data extent is a hole: blank without a read (a volume is mostly holes)
            let data = (0..<chips).map { store.dataBlocks($0) }
            return { data[$0.cs].contains($0.page / N72NAND.pagesPerBlock) ? try store.read($0) : blankRecord }
        }
        let legacy = LegacyReader(base: base, overlay: overlay)
        return { try legacy.read($0) }
    }

    // MARK: Migration

    /// The overlay's page directories: what goes when a device leaves format 1.
    static func overlayFiles(_ overlay: URL) -> [String] {
        (0..<4).map { "cs\($0)" }.filter {
            FileManager.default.fileExists(atPath: overlay.appendingPathComponent($0).path)
        }
    }

    /// Whether `overlay` holds any page or erase marker, so the live NAND differs from the base.
    static func overlayServes(_ overlay: URL?) -> Bool {
        guard let overlay else { return false }
        return LegacyReader(base: overlay, overlay: overlay).overlayNames.contains {
            $0.contains { LegacyReader.page($0) != nil || LegacyReader.erased($0) != nil }
        }
    }

    /// `base` (a page directory) as an image store at `baseOut`, and `liveOut` (when `overlay` serves pages): a clone
    /// of `baseOut` with the overlay applied, as the FMSS read it. `step` after each chip select (base, then live).
    static func convert(base: URL, overlay: URL?, baseOut: URL, liveOut: URL?, step: () -> Void = {}) throws {
        let legacy = LegacyReader(base: base, overlay: nil)
        do {
            let store = try Store(create: baseOut)
            for cs in 0..<chips {
                defer { step() }  // a chip select done: the migration's progress
                for name in legacy.baseNames[cs] {
                    guard let page = LegacyReader.page(name) else { continue }
                    let p = N72NAND.Page(cs: cs, page: page)
                    guard page < pagesPerChip else {
                        throw FirmwareError(.unsupported, "\(base.path): cs\(cs)/\(name)")
                    }
                    let record = try legacy.read(p)
                    if record != blankRecord { try store.write(p, record) }  // a blank page stays a hole
                }
            }
            try store.sync()
        }
        guard let liveOut, let overlay, overlayServes(overlay) else { return }
        let fm = FileManager.default
        try fm.createDirectory(at: liveOut, withIntermediateDirectories: false)
        for file in try fm.contentsOfDirectory(atPath: baseOut.path) {  // file by file; baseOut isn't locked yet
            let source = baseOut.appendingPathComponent(file)
            guard clonefile(source.path, liveOut.appendingPathComponent(file).path, 0) == 0 else {
                throw FirmwareError(.internal, "clone \(source.path): \(String(cString: strerror(errno)))")
            }
        }
        let live = try Store(liveOut, writable: true)
        let guest = LegacyReader(base: base, overlay: overlay)
        let zeros = [UInt8](repeating: 0, count: blockBytes)
        for cs in 0..<chips {
            defer { step() }
            // marked blocks first (blank, as their stored zeros), then the overlay's pages over them
            for block in guest.overlayNames[cs].compactMap(LegacyReader.erased) {
                guard block < blocksPerChip else { throw FirmwareError(.unsupported, "\(overlay.path): blk\(block)") }
                try K48NANDImage.write(live.fds[cs], zeros[...], at: block * blockBytes)
            }
            for page in guest.overlayNames[cs].compactMap(LegacyReader.page) {
                guard page < pagesPerChip else { throw FirmwareError(.unsupported, "\(overlay.path): cs\(cs)/\(page)") }
                let p = N72NAND.Page(cs: cs, page: page)
                try live.write(p, try guest.read(p))
            }
        }
        try live.sync()
    }

    /// Every page of `baseOut` reads as `base` alone did and of `liveOut` as `base` under `overlay` did, byte for byte,
    /// data and spare; a page no file names reads blank in all of them. Independent of `convert`: it reads both
    /// formats back.
    static func verify(base: URL, overlay: URL?, baseOut: URL, liveOut: URL?, step: () -> Void = {}) throws {
        let serves = overlayServes(overlay)
        guard (liveOut != nil) == serves else {
            throw FirmwareError(.internal, "the live NAND must exist exactly when the overlay serves pages")
        }
        let legacyBase = LegacyReader(base: base, overlay: nil)
        let legacyGuest = LegacyReader(base: base, overlay: serves ? overlay : nil)
        let newBase = try Store(baseOut)
        let newLive = try liveOut.map { try Store($0) }
        let named = legacyGuest.pages
        var block = [UInt8](repeating: 0, count: blockBytes)
        for cs in 0..<chips {
            defer { step() }
            var blocks = newBase.dataBlocks(cs)
            if let newLive { blocks.formUnion(newLive.dataBlocks(cs)) }
            for p in named where p.cs == cs { blocks.insert(p.page / N72NAND.pagesPerBlock) }
            for b in blocks.sorted() {
                for (store, legacy, what) in [(newBase, legacyBase, "base")]
                    + (newLive.map { [($0, legacyGuest, "live")] } ?? [])
                {
                    try store.readBlock(cs: cs, block: b, into: &block)
                    xor(&block, 0)
                    for i in 0..<N72NAND.pagesPerBlock {
                        let p = N72NAND.Page(cs: cs, page: b * N72NAND.pagesPerBlock + i)
                        guard K48NANDImage.same(block, i * stride, try legacy.read(p), 0, stride) else {
                            throw FirmwareError(.internal, "cs\(cs) page \(p.page): the \(what) image differs")
                        }
                    }
                }
            }
        }
    }
}
