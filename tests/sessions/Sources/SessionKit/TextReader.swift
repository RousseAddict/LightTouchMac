import CoreML
import Foundation
import Vision

/// The text Vision reads on an image, for every check that reads the screen. Vision runs its text model from a compiled
/// copy in ~/Library/Caches/<executable name>, which every same-named driver shares. Once that copy is deleted or
/// rebuilt under a running process (macOS purges Caches when the disk is nearly full; another driver rebuilds it), each
/// later read in that process fails with e5rtError 13 and reads nothing: the Setup walk then saw blank pages until its
/// 80 ran out (n90ap-11D257 frozen on the country list, n81ap/n88ap 10B500 on the language page, Terms or Apple ID).
/// A read that fails is made again on the CPU, which loads the model afresh and puts the process right.
public enum TextReader {
    /// Each line read, best candidate first, in Vision's coordinates (bottom-left origin, 0...1); empty if both
    /// reads fail.
    public static func read(_ handler: VNImageRequestHandler, languageCorrection: Bool = true)
        -> [VNRecognizedTextObservation]
    {
        for cpu in [false, true] {
            let request = VNRecognizeTextRequest()
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = languageCorrection
            if cpu,
                let device = MLComputeDevice.allComputeDevices.first(where: {
                    if case .cpu = $0 { true } else { false }
                })
            {
                try? request.setComputeDevice(device, for: .main)
            }
            if (try? handler.perform([request])) != nil { return request.results ?? [] }
        }
        return []
    }

    public static func read(_ url: URL, languageCorrection: Bool = true) -> [VNRecognizedTextObservation] {
        read(VNImageRequestHandler(url: url), languageCorrection: languageCorrection)
    }
}
