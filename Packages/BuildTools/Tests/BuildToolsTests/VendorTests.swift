import Foundation
import Testing

@testable import BuildTools

struct VendorTests {
    func scratch() throws -> URL {
        let dir = files.temporaryDirectory.appendingPathComponent("vendor-tests-\(UUID().uuidString)")
        try files.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    func touch(_ file: URL) throws {
        try files.createDirectory(at: file.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data("x".utf8).write(to: file)
    }

    /// Finder's .DS_Store in a tree (work/, a package checkout, the patches) is neither walked nor listed, so the
    /// license copy over the Swift checkouts no longer opens one as a package directory.
    @Test func finderLitterIsIgnored() throws {
        let dir = try scratch()
        defer { remove(dir) }
        for name in [".DS_Store", "a/.DS_Store", "a/LICENSE", "b/c.txt"] { try touch(dir.appendingPathComponent(name)) }
        #expect(walk(dir) == ["a/LICENSE", "b/c.txt"])
        #expect(try entries(dir).map(\.lastPathComponent) == ["a", "b"])
        #expect(try entries(dir.appendingPathComponent("a")).map(\.lastPathComponent) == ["LICENSE"])
    }

    /// An interrupted static build (libcrypto.a there, no static-build.json yet) is rebuilt; a finished one is not.
    @Test func staticRootNeedsItsRecord() throws {
        let dir = try scratch()
        defer { remove(dir) }
        try touch(dir.appendingPathComponent("prefix/lib/libcrypto.a"))
        #expect(!Vendor.staticComplete(dir))
        try writeJSON(["arch": "arm64"], to: dir.appendingPathComponent("static-build.json"))
        #expect(Vendor.staticComplete(dir))
    }

    /// A second holder of the vendor lock waits (and says so) until the first lets go.
    @Test func secondRunWaitsForTheLock() async throws {
        let dir = try scratch()
        defer { remove(dir) }
        let first = try Vendor.lock(dir) {}
        let second = Task.detached {
            var waited = false
            let fd = try Vendor.lock(dir) { waited = true }
            close(fd)
            return (waited, Date())
        }
        try await Task.sleep(for: .milliseconds(300))
        let released = Date()
        close(first)
        let (waited, acquired) = try await second.value
        #expect(waited && acquired >= released)
    }

    func lock(_ dir: URL, guestTools: String) throws -> URL {
        let lock = dir.appendingPathComponent("device.lock.json")
        try writeJSON(["inputs": ["guest_tools": guestTools]], to: lock)
        return lock
    }

    /// firmwarekit records the guest tools path it was given; through a symlinked vendor root that is the unresolved
    /// path, which the check accepts as the resolved one, and the other way round; another directory is refused.
    @Test func lockNamesTheGuestToolsThroughSymlinks() throws {
        let dir = try scratch()
        defer { remove(dir) }
        let real = dir.appendingPathComponent("real.noindex/ipad-guest-tools")
        try files.createDirectory(at: real, withIntermediateDirectories: true)
        try files.createSymbolicLink(
            at: dir.appendingPathComponent("link"),
            withDestinationURL: dir.appendingPathComponent("real.noindex")
        )
        let linked = dir.appendingPathComponent("link/ipad-guest-tools")
        #expect(Vendor.preparedWith(linked, lock: try lock(dir, guestTools: linked.path)))
        #expect(Vendor.preparedWith(real, lock: try lock(dir, guestTools: linked.path)))
        #expect(Vendor.preparedWith(linked, lock: try lock(dir, guestTools: MergeNative.real(real.path))))
        let other = dir.appendingPathComponent("other")
        try files.createDirectory(at: other, withIntermediateDirectories: true)
        #expect(!Vendor.preparedWith(linked, lock: try lock(dir, guestTools: other.path)))
    }

    /// A vendor directory or static build complete only in the old root is used there; an incomplete one, one the
    /// new root has, or any with LTM_VENDOR_ROOT set (no legacy root) is under the new root.
    @Test func legacyRootIsReadWhereComplete() throws {
        let home = try scratch()
        defer { remove(home) }
        let root = home.appendingPathComponent("Developer/ltm-vendor.noindex")
        let legacy = home.appendingPathComponent("Developer/ltm-vendor")
        try files.createDirectory(at: legacy.appendingPathComponent("def"), withIntermediateDirectories: true)
        try touch(legacy.appendingPathComponent("abc/vendor.json"))
        func cached(_ name: String, legacy: URL?) -> URL {
            Vendor.cached(name, record: "vendor.json", root: root, legacy: legacy)
        }
        #expect(cached("abc", legacy: legacy) == legacy.appendingPathComponent("abc"))
        #expect(cached("def", legacy: legacy) == root.appendingPathComponent("def"))
        #expect(cached("abc", legacy: nil) == root.appendingPathComponent("abc"))
        try files.createDirectory(at: root.appendingPathComponent("abc"), withIntermediateDirectories: true)
        #expect(cached("abc", legacy: legacy) == root.appendingPathComponent("abc"))
    }

    /// pack-base reuses the chunks of this vendor directory's own packed built-in iPod, else of the newest one under
    /// the root; an old single-file base (no index.json) offers none.
    @Test func previousBuiltInIsOwnElseTheNewest() throws {
        let root = try scratch()
        defer { remove(root) }
        func packed(_ key: String, age: TimeInterval) throws -> URL {
            let itbase = root.appendingPathComponent("\(key)/Resources/Device/\(Vendor.builtIn).itbase")
            try touch(itbase.appendingPathComponent("index.json"))
            try files.setAttributes(
                [.modificationDate: Date(timeIntervalSinceNow: -age)],
                ofItemAtPath: itbase.appendingPathComponent("index.json").path
            )
            return itbase
        }
        let current = root.appendingPathComponent("current")
        #expect(Vendor.previousBuiltIn(current, root: root) == nil)
        try touch(root.appendingPathComponent("blob/Resources/Device/\(Vendor.builtIn).itbase"))  // format 1: a file
        #expect(Vendor.previousBuiltIn(current, root: root) == nil)
        _ = try packed("older", age: 100)
        let newer = try packed("newer", age: 10)
        #expect(
            Vendor.previousBuiltIn(current, root: root)?.resolvingSymlinksInPath() == newer.resolvingSymlinksInPath()
        )
        let own = try packed("current", age: 1000)
        #expect(Vendor.previousBuiltIn(current, root: root)?.resolvingSymlinksInPath() == own.resolvingSymlinksInPath())
    }
}
