import Foundation
import Testing

@testable import LightTouchCore

/// A boot that comes up wrong is named: the recorded iPad 4.2.1 boot (both volumes mounted) has no fault, and lines from
/// real logs (the iPhone 3GS 3.1.3 data volume refused, issue 97; a crashed mediaserverd; a kernel panic) each give
/// theirs, through the whole-log judge sessions single runs and through the app's serial watch.
struct GuestFaultsTests {
    static let refused = """
        com.apple.launchd 1\tcom.apple.launchd 1\t*** launchd[1] has started up. ***
        Running fsck on the boot volume...
           Invalid content in Journal
        /dev/disk0s1 on / (hfs, local, noatime)
        mount_hfs: Invalid argument
        Bug: launchctl.c:3683 (23906):2: fwexec(mount_tool, NULL) != -1
        """

    @Test func theRecordedBootHasNoFault() throws {
        let log = try Data(contentsOf: repositoryRoot.appendingPathComponent("tests/fixtures/serial-k48ap-8C148.log"))
        #expect(GuestFaults.faults(log: String(decoding: log, as: UTF8.self), dataVolume: true) == [])
    }

    @Test func anUnmountedDataVolumeIsAFault() {
        let faults = GuestFaults.faults(log: Self.refused, dataVolume: true)
        #expect(faults.contains { $0.hasPrefix("the data volume didn't mount") && $0.hasSuffix("(on 1 of 1 boots)") })
        #expect(faults.contains { $0.hasPrefix("launchd couldn't mount") })
        #expect(faults.contains { $0.hasPrefix("a volume's journal is unreadable") })
        // A one-volume device (the iPod touch 2G, the iPhone 2G) has no /private/var line to miss.
        #expect(
            !GuestFaults.faults(log: "/dev/disk0s1 on / (hfs, local)\n", dataVolume: false).contains {
                $0.hasPrefix("the data volume")
            }
        )
        // A second boot that mounts it doesn't hide the first that didn't.
        let twice = Self.refused + "\n/dev/disk0s1 on / (hfs)\n/dev/disk0s2 on /private/var (hfs)\n"
        #expect(GuestFaults.faults(log: twice, dataVolume: true).contains { $0.hasSuffix("(on 1 of 2 boots)") })
    }

    @Test func crashesPanicsAndFailedChecksAreFaults() {
        let log = """
            Oct 17 11:11:18 launchd[1]: 16/com.apple.mediaserverd: Exited abnormally: Abort trap
            Oct 17 11:11:19 launchd[1]: 16/com.apple.SpringBoard: Exited: Terminated
            fsck exited with status: 8
            panic(cpu 0 caller 0x80a74efb): "CDMA: client driver(s) left channel(s) 0x2 active when sleeping"
            fsck exited with status: 0
            """
        let faults = GuestFaults.faults(log: log, dataVolume: false)
        #expect(faults.count == 3, "\(faults)")
        #expect(faults.contains { $0.hasPrefix("a system process crashed (1×): Oct 17") })
        #expect(faults.contains { $0.hasPrefix("the file system check failed (1×): fsck exited with status: 8") })
        #expect(faults.contains { $0.hasPrefix("the iOS kernel panicked") })
    }

    /// The app's watch sees the same: the phrases in order, across writes, then the mount rule once iOS answers.
    @Test func theAppsWatchSeesTheFaults() async throws {
        let seen = BootStageTests.Seen()
        let watch = LogPipeReader.LogWatch(phrases: GuestFaults.watched) { seen.add($0) }
        let bytes = Data(Self.refused.utf8)
        for start in stride(from: 0, to: bytes.count, by: 7) { watch.scan(bytes[start..<min(start + 7, bytes.count)]) }
        let phrases = Set(seen.phrases)
        #expect(phrases == ["Invalid content in Journal", GuestFaults.systemMounted, "fwexec(mount_tool"])
        #expect(GuestFaults.dataVolumeFault(seen: phrases, dataVolume: true) != nil)
        #expect(GuestFaults.dataVolumeFault(seen: phrases, dataVolume: false) == nil)
        #expect(
            GuestFaults.dataVolumeFault(seen: phrases.union([GuestFaults.dataMounted]), dataVolume: true) == nil
        )
    }
}
