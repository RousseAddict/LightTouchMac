import CoreML
import Foundation
import Vision

/// The text Vision reads on an image, for every check that reads the screen. Vision runs its text model through a
/// compiled-model cache in ~/Library/Caches/<executable name>/com.apple.e5rt.e5bundlecache, which every same-named driver
/// shares. When that cache is deleted under a running process (macOS purges Caches when the disk is nearly full; another
/// driver clears it), or is written while the host is short of disk or busy, reads fail with e5rtError 13 and read
/// nothing, every one after it in that process too: the phone Setup walk then took no step on the pages it saw until
/// its 80 ran out ("Setup still up after 80 pages" on n90ap-11D257's country list, n88ap-10B500's language page, Terms
/// and Apple ID), or Setup was still frontmost at the Home check. A read that fails is made again on the CPU, which
/// loads the model afresh; if that fails too, the cache is a bad one: it goes, and the read is made once more, which
/// compiles it again.
public enum TextReader {
    /// Each line read, best candidate first, in Vision's coordinates (bottom-left origin, 0...1); empty if every read
    /// fails.
    public static func read(_ handler: VNImageRequestHandler, languageCorrection: Bool = true)
        -> [VNRecognizedTextObservation]
    {
        for attempt in 0..<3 {
            if attempt == 2 { try? FileManager.default.removeItem(at: cache) }
            let request = VNRecognizeTextRequest()
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = languageCorrection
            if attempt == 1,
                let device = MLComputeDevice.allComputeDevices.first(where: {
                    if case .cpu = $0 { true } else { false }
                })
            {
                try? request.setComputeDevice(device, for: .main)
            }
            do {
                try handler.perform([request])
                if attempt > 0 {
                    FileHandle.standardError.write(Data("TextReader: read on attempt \(attempt + 1)\n".utf8))
                }
                return request.results ?? []
            } catch {
                FileHandle.standardError.write(Data("TextReader: attempt \(attempt + 1) failed: \(error)\n".utf8))
            }
        }
        return []
    }

    public static func read(_ url: URL, languageCorrection: Bool = true) -> [VNRecognizedTextObservation] {
        read(VNImageRequestHandler(url: url), languageCorrection: languageCorrection)
    }

    /// This executable's compiled-model cache.
    static var cache: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(ProcessInfo.processInfo.processName)
            .appendingPathComponent("com.apple.e5rt.e5bundlecache")
    }
}
