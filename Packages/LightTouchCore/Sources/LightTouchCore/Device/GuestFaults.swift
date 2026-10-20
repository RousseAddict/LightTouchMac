// What a boot's serial log shows went wrong inside iOS while the device still came up: the data volume left
// unmounted (so /private/var, and everything the device writes, stays on the system volume), a file system check
// that failed, a system process that crashed, a kernel panic. Each of these left devices looking fine for months
// (issue 97's iPhone 3GS 3.1.x data volumes never mounted). The app watches for them as the guest prints them
// (EmulatorController.openSerialLog) and logs each as an error; sessions single fails a run whose log shows one.
// Pure Foundation; LightTouchCoreTests' GuestFaultsTests.

import Foundation

public nonisolated enum GuestFaults {
    /// Phrases that are a fault wherever they appear, and what each means.
    public static let phrases: [String: String] = [
        "panic(cpu ": "the iOS kernel panicked",
        "Exited abnormally": "a system process crashed",
        "fwexec(mount_tool": "launchd couldn't mount the device's volumes",
        "Invalid content in Journal": "a volume's journal is unreadable",
    ].merging((1...9).map { ("fsck exited with status: \($0)", "the file system check failed") }) { a, _ in a }

    /// The lines launchd prints as it mounts the fstab (mount -v): the system volume, then the data volume.
    public static let systemMounted = " on / (", dataMounted = " on /private/var ("

    /// Everything the serial watch looks for.
    public static var watched: [String] { Array(phrases.keys) + [systemMounted, dataMounted] }

    /// The data volume fault: launchd printed the system volume's mount and, by the time iOS answered, never the data
    /// volume's. `dataVolume`: the device has a data partition (the recipe's data_size "partition"). A board whose
    /// kernel console is off prints neither line, so nothing is judged there.
    public static func dataVolumeFault(seen: Set<String>, dataVolume: Bool) -> String? {
        dataVolume && seen.contains(systemMounted) && !seen.contains(dataMounted) ? unmounted : nil
    }
    static let unmounted =
        "the data volume didn't mount: /private/var, and everything the device writes, is on the system volume"

    /// Every fault in a whole serial log (all the boots in it), one line each with what the log said.
    public static func faults(log: String, dataVolume: Bool) -> [String] {
        let lines = log.split(whereSeparator: \.isNewline)
        var out: [String] = []
        for (phrase, meaning) in phrases.sorted(by: { $0.key < $1.key }) {
            let hits = lines.filter { $0.contains(phrase) }
            guard let first = hits.first else { continue }
            out.append("\(meaning) (\(hits.count)×): \(first.trimmingCharacters(in: .whitespaces).prefix(160))")
        }
        let boots = lines.filter { $0.contains(systemMounted) }.count
        let data = lines.filter { $0.contains(dataMounted) }.count
        if dataVolume, data < boots {
            out.append(unmounted + " (on \(boots - data) of \(boots) boots)")
        }
        return out
    }
}
