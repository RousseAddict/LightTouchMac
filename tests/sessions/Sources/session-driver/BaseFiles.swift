import FirmwareKit
import Foundation

/// The first of `paths` (volume-relative) on the base's system volume, read offline: the volume rebuilt from the
/// base's NAND store (VolumeRebuild, no overlay) into `work`, which is removed after. For a guest without an agent.
func baseSystemFile(base: URL, paths: [String], work: URL) -> (path: String, data: Data)? {
    defer { try? FileManager.default.removeItem(at: work) }
    guard
        let image = try? VolumeRebuild.rebuild(
            base: base.appendingPathComponent("nand"),
            overlay: nil,
            into: work,
            only: ["system"]
        ).first?.image,
        let volume = try? HFSPlusVolume(image)
    else { return nil }
    for path in paths {
        if let record = try? volume.record(at: path), let data = try? volume.contents(record) { return (path, data) }
    }
    return nil
}

/// The crash reports the base itself carries (its preparation's boots wrote them), as the guest's crash report
/// service names them: paths under mobile/Library/Logs/CrashReporter on the data volume (or private/var/… on a board
/// with one volume). A guest whose clock starts at a pinned date every boot (a dated beta) gives them ages no
/// different from this run's own, so they are told apart by being in the base. nil where the base can't be read.
/// ponytail: by name; a report this run writes under a base report's name (the same second of a pinned clock) is
/// missed. Compare sizes too if that ever happens.
func baseCrashReports(base: URL, work: URL) -> Set<String>? {
    defer { try? FileManager.default.removeItem(at: work) }
    let nand = base.appendingPathComponent("nand")
    for (volume, folder) in [
        ("data", "mobile/Library/Logs/CrashReporter"), ("system", "private/var/mobile/Library/Logs/CrashReporter"),
    ] {
        guard let image = try? VolumeRebuild.rebuild(base: nand, overlay: nil, into: work, only: [volume]).first?.image,
            let entries = try? HFSPlusVolume(image).listing(under: folder, hashes: false)
        else { continue }
        return Set(entries.map(\.path).filter { $0 != folder }.map { String($0.dropFirst(folder.count + 1)) })
    }
    return nil
}
