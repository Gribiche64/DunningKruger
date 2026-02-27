import CoreGraphics

/// Resolves overlapping name tags by alternating above/below the curve.
struct TagLayoutEngine {

    /// Estimated tag width in normalized coordinates per character
    /// (rough approximation — pixel font ~4px per char, chart ~700px drawable)
    private static let charWidthNorm: CGFloat = 0.009
    /// Minimum vertical offset from the curve (normalized)
    private static let baseOffset: CGFloat = 0.10
    /// Extra push if still overlapping (normalized)
    private static let pushStep: CGFloat = 0.05

    struct TagRect {
        let index: Int
        let x: CGFloat
        let y: CGFloat          // curve Y
        let halfWidth: CGFloat
        let halfHeight: CGFloat
        var offset: CGFloat     // positive = above curve, negative = below

        var minX: CGFloat { x - halfWidth }
        var maxX: CGFloat { x + halfWidth }
        var effectiveY: CGFloat { y + offset }
        var minY: CGFloat { effectiveY - halfHeight }
        var maxY: CGFloat { effectiveY + halfHeight }
    }

    /// Given an array of (index, normalizedX, curveY, nameLength),
    /// returns tag offsets indexed by original array position.
    static func resolveOverlaps(
        tags: [(index: Int, x: CGFloat, curveY: CGFloat, nameLength: Int)]
    ) -> [CGFloat] {
        guard !tags.isEmpty else { return [] }

        // Build rects (cap name length to match NameTagView truncation)
        var rects: [TagRect] = tags.map { tag in
            let cappedLen = min(tag.nameLength, 12)
            let hw = CGFloat(cappedLen) * charWidthNorm / 2 + 0.01
            let hh: CGFloat = 0.03  // approx tag height in normalized coords
            return TagRect(
                index: tag.index,
                x: tag.x,
                y: tag.curveY,
                halfWidth: hw,
                halfHeight: hh,
                offset: baseOffset  // default: above curve
            )
        }

        // Sort by x for sweep
        rects.sort { $0.x < $1.x }

        // Greedy sweep: alternate above/below when overlapping
        for i in 1..<rects.count {
            for j in stride(from: i - 1, through: max(0, i - 4), by: -1) {
                if overlaps(rects[j], rects[i]) {
                    // Flip side if same side
                    if rects[i].offset > 0 && rects[j].offset > 0 {
                        rects[i].offset = -baseOffset
                    } else if rects[i].offset < 0 && rects[j].offset < 0 {
                        rects[i].offset = baseOffset
                    }

                    // If still overlapping, push further
                    var attempts = 0
                    while overlaps(rects[j], rects[i]) && attempts < 5 {
                        if rects[i].offset > 0 {
                            rects[i].offset += pushStep
                        } else {
                            rects[i].offset -= pushStep
                        }
                        attempts += 1
                    }
                }
            }
        }

        // Map back to original indices
        var result = Array(repeating: CGFloat(0), count: tags.count)
        for rect in rects {
            result[rect.index] = rect.offset
        }
        return result
    }

    private static func overlaps(_ a: TagRect, _ b: TagRect) -> Bool {
        // Check X overlap
        guard a.maxX > b.minX && b.maxX > a.minX else { return false }
        // Check Y overlap
        guard a.maxY > b.minY && b.maxY > a.minY else { return false }
        return true
    }
}
