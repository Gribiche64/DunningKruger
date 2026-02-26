import Foundation
import CoreGraphics

// MARK: - Cubic Bezier Segment

struct CubicSegment {
    let p0: CGPoint
    let p1: CGPoint   // control 1
    let p2: CGPoint   // control 2
    let p3: CGPoint

    func evaluate(t: CGFloat) -> CGPoint {
        let mt = 1 - t
        let mt2 = mt * mt
        let mt3 = mt2 * mt
        let t2 = t * t
        let t3 = t2 * t

        let x = mt3 * p0.x + 3 * mt2 * t * p1.x + 3 * mt * t2 * p2.x + t3 * p3.x
        let y = mt3 * p0.y + 3 * mt2 * t * p1.y + 3 * mt * t2 * p2.y + t3 * p3.y
        return CGPoint(x: x, y: y)
    }
}

// MARK: - DK Curve Sampler

/// Pre-computes a lookup table from the DK curve's 4 cubic Bezier segments.
/// All coordinates are in normalized (0…1) space where y = confidence.
struct DKCurveSampler {

    /// The canonical DK curve segments (normalized coordinates)
    static let segments: [CubicSegment] = [
        CubicSegment(
            p0: CGPoint(x: 0.00, y: 0.15),
            p1: CGPoint(x: 0.05, y: 0.15),
            p2: CGPoint(x: 0.08, y: 0.95),
            p3: CGPoint(x: 0.15, y: 0.95)
        ),
        CubicSegment(
            p0: CGPoint(x: 0.15, y: 0.95),
            p1: CGPoint(x: 0.22, y: 0.95),
            p2: CGPoint(x: 0.30, y: 0.12),
            p3: CGPoint(x: 0.40, y: 0.12)
        ),
        CubicSegment(
            p0: CGPoint(x: 0.40, y: 0.12),
            p1: CGPoint(x: 0.50, y: 0.12),
            p2: CGPoint(x: 0.60, y: 0.45),
            p3: CGPoint(x: 0.70, y: 0.60)
        ),
        CubicSegment(
            p0: CGPoint(x: 0.70, y: 0.60),
            p1: CGPoint(x: 0.80, y: 0.72),
            p2: CGPoint(x: 0.90, y: 0.75),
            p3: CGPoint(x: 1.00, y: 0.75)
        ),
    ]

    // Lookup table: sorted by x, each entry is (x, y)
    private let table: [(x: CGFloat, y: CGFloat)]

    static let shared = DKCurveSampler()

    private init(samplesPerSegment: Int = 50) {
        var samples: [(x: CGFloat, y: CGFloat)] = []
        for seg in Self.segments {
            let count = samplesPerSegment
            for i in 0...count {
                let t = CGFloat(i) / CGFloat(count)
                let pt = seg.evaluate(t: t)
                samples.append((x: pt.x, y: pt.y))
            }
        }
        // Sort by x (should already be mostly sorted, but be safe)
        self.table = samples.sorted { $0.x < $1.x }
    }

    /// Returns the curve's Y value for a given normalized X,
    /// using binary-search + linear interpolation in the lookup table.
    func curveY(atX x: CGFloat) -> CGFloat {
        let clamped = min(max(x, 0), 1)

        // Binary search for the bracket
        var lo = 0
        var hi = table.count - 1

        while lo < hi - 1 {
            let mid = (lo + hi) / 2
            if table[mid].x <= clamped {
                lo = mid
            } else {
                hi = mid
            }
        }

        let a = table[lo]
        let b = table[hi]

        if abs(b.x - a.x) < 1e-9 {
            return a.y
        }

        let frac = (clamped - a.x) / (b.x - a.x)
        return a.y + frac * (b.y - a.y)
    }

    /// Snap a position: keep user's X, replace Y with the curve's Y at that X.
    func snap(_ position: CGPoint) -> CGPoint {
        let clampedX = min(max(position.x, 0), 1)
        return CGPoint(x: clampedX, y: curveY(atX: clampedX))
    }
}
