// The format 2 migration of an A4 or S5L8920 device (k48, n81, n90, n18, n88): its legacy NAND store and page
// overlay become an image store (base/nand, read-only) and the device's live NAND, a clone of it with the overlay's
// pages applied (overlay/nand, PreparedDeviceBoot.liveNAND), which the emulator writes in place. Lazy: a boot
// admission step (FirmwareBootAdmission), under the stopped lease, before the first start that needs it.
//
//   1. preflight: room for the new base, the live NAND's changes and the volume proof, plus 1 GiB;
//   2. intent work/migration.json (phase building), then build both into migrating/ (K48NANDImage.convert);
//   3. proof: every page of both images reads as before, byte for byte (K48NANDImage.verify), and the volumes rebuilt
//      from the new store hash as the ones rebuilt from the old (when the old one rebuilds);
//   4. intent phase committing; renames: base/nand and the overlay's chip files into legacy/, the new base and live
//      NAND into place; then the record, format 2, by an atomic replace;
//   5. legacy/ stays until a session ends in a clean stop (the helper's clean-stop marker), then goes.
//
// A failure before the record swap leaves the device as it was, in format 1 (the emulator still reads it), and the
// next start tries again. An interrupted run is recovered from the intent at the next admission: before the record
// swap the renames are reversed, after it they are finished.

import CryptoKit
import Darwin
import FirmwareSchema
import Foundation
import HostRuntime

public enum K48NANDMigration {
    /// The record format of a device whose NAND is an image store.
    public static let recordFormat = DeviceRecord.imageFormat

    /// The kill-at-each-step proofs' hook: LTM_TEST_MIGRATION_KILL=<checkpoint> SIGKILLs the process there.
    static func killHook(_ checkpoint: Checkpoint) {
        if ProcessInfo.processInfo.environment["LTM_TEST_MIGRATION_KILL"] == checkpoint.description {
            kill(getpid(), SIGKILL)
        }
    }

    /// Where a run can be cut short.
    public enum Checkpoint: Sendable, Equatable, CustomStringConvertible {
        case built
        case verified
        case renamed(Int)
        case recordWritten
        public var description: String {
            switch self {
            case .built: "built"
            case .verified: "verified"
            case .renamed(let n): "renamed-\(n)"
            case .recordWritten: "record"
            }
        }
    }

    struct Intent: Codable, Equatable {
        enum Phase: String, Codable { case building, committing }
        var phase: Phase
        /// Paths relative to the device directory, in commit order.
        var renames: [[String]]
    }

    struct Layout {
        let device: URL
        var intent: URL { device.appendingPathComponent("work/migration.json") }
        var migrating: URL { device.appendingPathComponent("migrating") }
        var legacy: URL { device.appendingPathComponent("legacy") }
        var record: URL { device.appendingPathComponent(DeviceRecord.name) }
        func url(_ relative: String) -> URL { device.appendingPathComponent(relative) }
    }

    /// The admission step. True when the device's storage changed (migrated, recovered, or its kept legacy files
    /// retired). A migration that fails leaves the device in format 1 and returns false; only a failed recovery
    /// throws (the device's storage is then in neither format, and must not boot).
    static func admit(
        _ owner: StoppedRecordOwner,
        log: (String) -> Void = { FirmwareDiagnostics.write(Data("\($0)\n".utf8)) },
        checkpoint: (Checkpoint) throws -> Void = killHook
    ) throws -> Bool {
        let layout = Layout(device: owner.device)
        let fm = FileManager.default
        var changed = false
        let cleanStop = PreparedDeviceBoot.cleanStopMarker(lease: owner.device.appendingPathComponent("work/lease"))
        defer { try? fm.removeItem(at: cleanStop) }  // it speaks for the session that just ended only
        if fm.fileExists(atPath: layout.intent.path) {
            let rolledBack = try recover(layout)
            log("NAND image migration: \(rolledBack ? "rolled back" : "finished") an interrupted run")
            if rolledBack { return true }  // the next start tries again, so a run that kills its process can't wedge it
            changed = true
        }
        let record = try DeviceRecord.object(Data(contentsOf: layout.record))
        let format = record["format"] as? Int ?? 1
        if format >= recordFormat {
            if fm.fileExists(atPath: layout.legacy.path), fm.fileExists(atPath: cleanStop.path) {
                try removeTree(layout.legacy)
                log("NAND image migration: removed the format 1 store after a clean stop")
                changed = true
            }
            return changed
        }
        guard let paths = owner.paths, eligible(record, base: paths.base, device: owner.device) else { return changed }
        do {
            try migrate(layout, base: paths.base, overlay: paths.overlay, log: log, checkpoint: checkpoint)
        } catch {
            log("NAND image migration: \(error); the device stays in format 1")
            if fm.fileExists(atPath: layout.intent.path) { _ = try recover(layout) }
            return changed
        }
        return true
    }

    /// A kboot board's format 1 record over its own legacy store (not a development base outside the device).
    static func eligible(_ record: [String: Any], base: URL, device: URL) -> Bool {
        guard HostRuntime.Board(rawValue: record["board"] as? String ?? "")?.isKBoot == true,
            (record["format"] as? Int ?? 1) < recordFormat,
            StoragePathAuthority.canonicalPath(base).hasPrefix(StoragePathAuthority.canonicalPath(device) + "/"),
            (try? K48NAND.storeFormat(base.appendingPathComponent("nand"))) == .legacy
        else { return false }
        return true
    }

    static func relative(_ url: URL, to device: URL) throws -> String {
        let root = StoragePathAuthority.canonicalPath(device) + "/"
        let path = StoragePathAuthority.canonicalPath(url)
        guard path.hasPrefix(root) else { throw FirmwareError(.internal, "\(url.path) is outside the device") }
        return String(path.dropFirst(root.count))
    }

    static func migrate(
        _ layout: Layout,
        base: URL,
        overlay: URL,
        log: (String) -> Void,
        checkpoint: (Checkpoint) throws -> Void
    ) throws {
        let fm = FileManager.default
        let nand = base.appendingPathComponent("nand")
        let geo = try K48NAND.geometry(store: nand)
        let serves = K48NANDImage.overlayServes(overlay, geo)
        let overlayFiles = fm.fileExists(atPath: overlay.path) ? K48NANDImage.overlayFiles(overlay) : []
        let needed =
            2 * allocated(nand) + overlayFiles.reduce(0) { $0 + allocated(overlay.appendingPathComponent($1)) }
            + (1 << 30)
        try StorageCapacity.require(needed, at: layout.device)

        let baseRel = try relative(base, to: layout.device)
        let overlayRel = try relative(overlay, to: layout.device)
        var renames = [["\(baseRel)/nand", "legacy/base-nand"]]
        renames += overlayFiles.map { ["\(overlayRel)/\($0)", "legacy/overlay/\($0)"] }
        renames.append(["migrating/base-nand", "\(baseRel)/nand"])
        if serves { renames.append(["migrating/nand", "\(overlayRel)/nand"]) }
        var intent = Intent(phase: .building, renames: renames)
        // A format 1 record with legacy/ beside it: a migrated edit generation that Erase has since discarded.
        for stale in [layout.migrating, layout.legacy] where fm.fileExists(atPath: stale.path) { try removeTree(stale) }
        try writeIntent(intent, layout)
        let started = Date()
        try fm.createDirectory(at: layout.migrating, withIntermediateDirectories: false)
        let baseOut = layout.migrating.appendingPathComponent("base-nand")
        let liveOut = serves ? layout.migrating.appendingPathComponent("nand") : nil
        let legacyOverlay = serves ? overlay : nil
        try K48NANDImage.convert(base: nand, overlay: legacyOverlay, baseOut: baseOut, liveOut: liveOut)
        try checkpoint(.built)
        try K48NANDImage.verify(base: nand, overlay: legacyOverlay, baseOut: baseOut, liveOut: liveOut)
        let volumes = try volumeProof(
            old: (nand, legacyOverlay),
            new: liveOut ?? baseOut,
            work: layout.migrating.appendingPathComponent("volumes")
        )
        log(
            String(
                format: "NAND image migration: built and verified in %.1f s (%@)",
                Date().timeIntervalSince(started),
                volumes
            )
        )
        try checkpoint(.verified)

        intent.phase = .committing
        try writeIntent(intent, layout)
        try unlock(base)
        try fm.createDirectory(at: layout.legacy.appendingPathComponent("overlay"), withIntermediateDirectories: true)
        for (i, pair) in renames.enumerated() {
            try move(layout.url(pair[0]), layout.url(pair[1]))
            try checkpoint(.renamed(i))
        }
        var record = try DeviceRecord.object(Data(contentsOf: layout.record))
        record["format"] = recordFormat
        try StorageGeneration.write(DeviceRecord.data(record), to: layout.record)
        try checkpoint(.recordWritten)
        try finish(layout, base: base)
    }

    /// The volumes rebuilt from `old` (a legacy store and overlay) and from `new` hash the same. A legacy store
    /// VolumeRebuild can't read proves nothing either way: the page proof stands alone then.
    static func volumeProof(old: (store: URL, overlay: URL?), new: URL, work: URL) throws -> String {
        func hashes(_ store: URL, _ overlay: URL?, _ into: URL) throws -> [String: String] {
            defer { try? FileManager.default.removeItem(at: into) }
            let volumes = try VolumeRebuild.rebuild(base: store, overlay: overlay, into: into)
            return try Dictionary(
                uniqueKeysWithValues: volumes.map { ($0.name, try Preparer.digest($0.image, SHA256())) }
            )
        }
        let before: [String: String]
        do { before = try hashes(old.store, old.overlay, work.appendingPathComponent("old")) } catch {
            return "volumes not compared: the format 1 store doesn't rebuild: \(error)"
        }
        let after = try hashes(new, nil, work.appendingPathComponent("new"))
        guard after == before else {
            throw FirmwareError(.internal, "the image store's volumes differ from the format 1 store's")
        }
        return "volumes \(before.keys.sorted().joined(separator: ", ")) hash the same"
    }

    /// Before the record swap: reverse the renames and drop the build (true). After it: finish them (false).
    static func recover(_ layout: Layout) throws -> Bool {
        let intent = try JSONDecoder().decode(Intent.self, from: Data(contentsOf: layout.intent))
        let format = (try DeviceRecord.object(Data(contentsOf: layout.record)))["format"] as? Int ?? 1
        let base = intent.renames.last { $0[0] == "migrating/base-nand" }.map {
            layout.url($0[1]).deletingLastPathComponent()
        }
        if intent.phase == .committing, format >= recordFormat {
            for pair in intent.renames { try move(layout.url(pair[0]), layout.url(pair[1])) }
            try finish(layout, base: base)
            return false
        }
        if intent.phase == .committing {
            if let base { try unlock(base) }
            for pair in intent.renames.reversed() { try move(layout.url(pair[0]), layout.url(pair[1]), back: true) }
            if let base { try lock(base) }
            // legacy/ and migrating/ go below: only once everything that went into them is back
            for pair in intent.renames where !FileManager.default.fileExists(atPath: layout.url(pair[0]).path) {
                throw FirmwareError(.internal, "NAND image migration rollback: \(pair[0]) is missing")
            }
        }
        for dir in [layout.migrating, layout.legacy] where FileManager.default.fileExists(atPath: dir.path) {
            try removeTree(dir)
        }
        try FileManager.default.removeItem(at: layout.intent)
        try StorageGeneration.sync(layout.intent.deletingLastPathComponent())
        return true
    }

    /// One commit rename, idempotent so an interrupted run's can be replayed: forward, `from` to `to` unless `to` is
    /// there (each destination appears only by its rename; base/nand's old store left by an earlier one); back, `to`
    /// to `from` only where the rename happened (`to` there, `from` gone).
    static func move(_ from: URL, _ to: URL, back: Bool = false) throws {
        let fm = FileManager.default
        if back {
            guard fm.fileExists(atPath: to.path), !fm.fileExists(atPath: from.path) else { return }
            return try move(to, from)
        }
        if fm.fileExists(atPath: to.path) { return }
        guard rename(from.path, to.path) == 0 else {
            throw FirmwareError(.internal, "rename \(from.path): \(String(cString: strerror(errno)))")
        }
        try StorageGeneration.sync(from.deletingLastPathComponent())
        try StorageGeneration.sync(to.deletingLastPathComponent())
    }

    static func finish(_ layout: Layout, base: URL?) throws {
        if let base { try lock(base) }
        if FileManager.default.fileExists(atPath: layout.migrating.path) { try removeTree(layout.migrating) }
        try FileManager.default.removeItem(at: layout.intent)
        try StorageGeneration.sync(layout.intent.deletingLastPathComponent())
    }

    static func writeIntent(_ intent: Intent, _ layout: Layout) throws {
        try StorageGeneration.write(JSONEncoder().encode(intent), to: layout.intent)
    }

    /// The published base is immutable (DeviceStateStorage.lockBase: uchg on it and its directories); its nand can
    /// only be renamed with that cleared on both.
    static func unlock(_ base: URL) throws {
        for dir in [base, base.appendingPathComponent("nand")] where FileManager.default.fileExists(atPath: dir.path) {
            guard chflags(dir.path, 0) == 0, chmod(dir.path, 0o700) == 0 else {
                throw FirmwareError(.internal, "unlock \(dir.path): \(String(cString: strerror(errno)))")
            }
        }
    }

    /// The base as preparation leaves it: the store read-only (Preparer.readOnly), the directories immutable.
    static func lock(_ base: URL) throws {
        let nand = base.appendingPathComponent("nand")
        if FileManager.default.fileExists(atPath: nand.path) {
            try Preparer.readOnly(nand)
            chflags(nand.path, UInt32(UF_IMMUTABLE))
        }
        chflags(base.path, UInt32(UF_IMMUTABLE))
    }

    /// Removes a tree whose directories may be immutable or read-only (a kept legacy base).
    static func removeTree(_ url: URL) throws {
        let fm = FileManager.default
        var directories = [url]
        if let walk = fm.enumerator(at: url, includingPropertiesForKeys: [.isDirectoryKey, .isSymbolicLinkKey]) {
            for case let item as URL in walk {
                let values = try? item.resourceValues(forKeys: [.isDirectoryKey, .isSymbolicLinkKey])
                if values?.isDirectory == true, values?.isSymbolicLink != true { directories.append(item) }
            }
        }
        for dir in directories {
            chflags(dir.path, 0)
            chmod(dir.path, 0o700)
        }
        try fm.removeItem(at: url)
    }

    /// Bytes `url` occupies (a file or a directory's files).
    static func allocated(_ url: URL) -> Int64 {
        var st = stat()
        guard lstat(url.path, &st) == 0 else { return 0 }
        guard st.st_mode & S_IFMT == S_IFDIR else { return Int64(st.st_blocks) * 512 }
        let names = (try? FileManager.default.contentsOfDirectory(atPath: url.path)) ?? []
        return names.reduce(0) { $0 + allocated(url.appendingPathComponent($1)) }
    }
}
