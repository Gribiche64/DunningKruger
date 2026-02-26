import SwiftUI

struct DKCurveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        func pt(_ p: CGPoint) -> CGPoint {
            CGPoint(x: p.x * w, y: (1 - p.y) * h)
        }

        let segs = DKCurveSampler.segments

        guard let first = segs.first else { return path }
        path.move(to: pt(first.p0))

        for seg in segs {
            path.addCurve(
                to: pt(seg.p3),
                control1: pt(seg.p1),
                control2: pt(seg.p2)
            )
        }

        return path
    }
}

/// Pixelated grid lines for retro feel
struct RetroGridLines: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cols = 10
        let rows = 8

        for i in 1..<cols {
            let x = rect.width * CGFloat(i) / CGFloat(cols)
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: rect.height))
        }

        for i in 1..<rows {
            let y = rect.height * CGFloat(i) / CGFloat(rows)
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: rect.width, y: y))
        }

        return path
    }
}
