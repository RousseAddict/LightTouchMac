import Accelerate

/// How much faster a recorded sound came out than its source: 2 when samples made for 22.05 kHz are played at
/// 44.1 kHz (an octave up, in half the time), 1 when they are played at the rate they were made for. Found as the
/// speed-up of the source that lines up best, sample for sample, with the loudest stretch of the recording
/// (normalized cross-correlation over every offset), so it needs no listening and holds for any sound.
public nonisolated enum SoundScale {
    /// The stretch of the recording compared, in seconds.
    static let window = 0.025

    /// The factor, from 0.4 to 2.6 to within 0.5%, and how well the source at that speed matches (the correlation,
    /// at most 1); nil if either sound is silent or too short.
    public static func scale(
        reference: [Float],
        referenceRate: Double,
        recording: [Float],
        recordingRate: Double
    ) -> (factor: Double, match: Double)? {
        let width = Int(window * recordingRate)
        guard recording.count > width, reference.count > 1, let loudest = loudest(recording, width: width) else {
            return nil
        }
        let stretch = Array(recording[loudest..<loudest + width])
        func match(_ k: Double) -> Double {
            correlation(stretch, resampled(reference, step: k * referenceRate / recordingRate))
        }
        var best = stride(from: 0.4, through: 2.6, by: 0.02).map { ($0, match($0)) }.max { $0.1 < $1.1 }!
        for k in stride(from: best.0 - 0.02, through: best.0 + 0.02, by: 0.005) where k > 0 {
            let m = match(k)
            if m > best.1 { best = (k, m) }
        }
        return best.1 > 0 ? (best.0, best.1) : nil
    }

    /// Where the `width` samples of `x` with the most energy start, or nil if `x` is silent.
    static func loudest(_ x: [Float], width: Int) -> Int? {
        let energy = x.map { Double($0) * Double($0) }
        var sum = energy[0..<width].reduce(0, +)
        var best = (start: 0, sum: sum)
        for start in 1...(x.count - width) {
            sum += energy[start + width - 1] - energy[start - 1]
            if sum > best.sum { best = (start, sum) }
        }
        return best.sum > 0 ? best.start : nil
    }

    /// `x` read every `step` samples (linear interpolation).
    static func resampled(_ x: [Float], step: Double) -> [Float] {
        let count = Int(Double(x.count - 1) / step)
        return (0..<count).map { i in
            let p = Double(i) * step
            let j = Int(p)
            let t = Float(p - Double(j))
            return x[j] * (1 - t) + x[j + 1] * t
        }
    }

    /// The best normalized cross-correlation of `stretch` against `source` at any offset where it fits.
    static func correlation(_ stretch: [Float], _ source: [Float]) -> Double {
        let n = stretch.count
        guard source.count >= n else { return -1 }
        let lags = source.count - n + 1
        var dots = [Float](repeating: 0, count: lags)
        vDSP_conv(source, 1, stretch, 1, &dots, 1, vDSP_Length(lags), vDSP_Length(n))
        let norm = vDSP.sumOfSquares(stretch)
        // The source's energy under the stretch at each offset, summed afresh at each (a running sum loses the
        // quiet stretches to rounding); offsets where the source is near silent don't count.
        var energy = [Float](repeating: 0, count: lags)
        vDSP_conv(
            vDSP.square(source),
            1,
            [Float](repeating: 1, count: n),
            1,
            &energy,
            1,
            vDSP_Length(lags),
            vDSP_Length(n)
        )
        let floor = (energy.max() ?? 0) * 1e-4
        var best = -1.0
        for lag in 0..<lags where energy[lag] > floor {
            best = max(best, Double(dots[lag]) / (Double(energy[lag]) * Double(norm)).squareRoot())
        }
        return best
    }
}
