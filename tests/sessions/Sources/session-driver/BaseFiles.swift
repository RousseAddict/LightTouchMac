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
