import Foundation
import ImageIO
import UniformTypeIdentifiers
import Vision

/// The text Vision reads on an image, for every check that reads the screen, each read in a child process (this
/// executable again, `serveChild`). Vision runs its text model through a compiled copy in
/// ~/Library/Caches/<process name>/com.apple.e5rt.e5bundlecache that refers to a model aned compiled for the Neural
/// Engine. Once either is replaced or dropped under a process that has loaded it (another build of the driver compiling
/// the same model: each SwiftPM build signs as its own identity, and each worktree and the release have their own;
/// aned recompiling under load), every later read in that process fails with e5rtError 13 and reads nothing, on the
/// CPU too and with the cache cleared, so the phone Setup walk took no step until its 80 pages ran out ("Setup still up
/// after 80 pages", or Setup still frontmost at the Home check, on n81, n88 and n90 whenever other agents' drivers ran).
/// A fresh process loads the model afresh. Each build reads through a cache of its own (`isolate`), which processes
/// of the same build share safely; a read that fails is made again, and the third time with that cache cleared, which
/// compiles it again.
public enum TextReader {
    /// A line read: its best candidate and its center as a touch point (top-left origin, 0...1).
    public struct Line: Codable, Equatable, Sendable {
        public let text: String
        public let x: Double
        public let y: Double
    }

    /// Each line read on the image; empty if every read fails.
    public static func read(_ url: URL, languageCorrection: Bool = true) -> [Line] {
        isolate
        for attempt in 0..<3 {
            if attempt == 2 { try? FileManager.default.removeItem(at: cache) }
            if let lines = child(url, languageCorrection) {
                if attempt > 0 {
                    FileHandle.standardError.write(Data("TextReader: read on attempt \(attempt + 1)\n".utf8))
                }
                return lines
            }
            FileHandle.standardError.write(Data("TextReader: attempt \(attempt + 1) failed\n".utf8))
        }
        return []
    }

    public static func read(_ image: CGImage, languageCorrection: Bool = true) -> [Line] {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("text-\(UUID().uuidString).png")
        defer { try? FileManager.default.removeItem(at: url) }
        guard let out = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else {
            return []
        }
        CGImageDestinationAddImage(out, image, nil)
        guard CGImageDestinationFinalize(out) else { return [] }
        return read(url, languageCorrection: languageCorrection)
    }

    /// The child's side: with LTM_TEXT_READ=<png>\t<0|1> set, reads the image, writes the lines as JSON to stdout and
    /// exits (1 if Vision fails). Called first thing in each executable that reads.
    public static func serveChild() {
        guard let job = ProcessInfo.processInfo.environment[childKey]?.split(separator: "\t"), job.count == 2 else {
            return
        }
        isolate
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = job[1] == "1"
        do {
            try VNImageRequestHandler(url: URL(fileURLWithPath: String(job[0]))).perform([request])
        } catch {
            FileHandle.standardError.write(Data("TextReader: \(error)\n".utf8))
            exit(1)
        }
        let lines = (request.results ?? []).compactMap { o in
            o.topCandidates(1).first.map { Line(text: $0.string, x: o.boundingBox.midX, y: 1 - o.boundingBox.midY) }
        }
        FileHandle.standardOutput.write((try? JSONEncoder().encode(lines)) ?? Data("[]".utf8))
        exit(0)
    }

    static let childKey = "LTM_TEXT_READ"

    static func child(_ url: URL, _ languageCorrection: Bool) -> [Line]? {
        let p = Process()
        p.executableURL = Bundle.main.executableURL
        p.environment = ProcessInfo.processInfo.environment.merging(
            [childKey: "\(url.path)\t\(languageCorrection ? 1 : 0)"]
        ) { $1 }
        let out = Pipe()
        p.standardOutput = out
        p.standardInput = FileHandle.nullDevice
        do { try p.run() } catch { return nil }
        let data = out.fileHandleForReading.readDataToEndOfFile()
        p.waitUntilExit()
        guard p.terminationStatus == 0 else { return nil }
        return try? JSONDecoder().decode([Line].self, from: data)
    }

    /// Names the process `<name>.vision/<inode>-<mtime>` of its executable before Vision first reads, so its cache is
    /// ~/Library/Caches/<name>.vision/<build>/. ponytail: old builds' caches (about 150 KB each) stay until macOS
    /// purges Caches.
    static let isolate: Void = {
        let info = ProcessInfo.processInfo
        var st = stat()
        guard stat(Bundle.main.executablePath ?? CommandLine.arguments[0], &st) == 0 else { return }
        info.processName = "\(info.processName).vision/\(st.st_ino)-\(st.st_mtimespec.tv_sec)"
    }()

    /// This build's compiled-model cache.
    static var cache: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(ProcessInfo.processInfo.processName)
            .appendingPathComponent("com.apple.e5rt.e5bundlecache")
    }
}
