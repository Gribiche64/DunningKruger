import SwiftUI

// MARK: - 3x5 Pixel Font

/// Tiny pixel font — each character is 3 wide × 5 tall
struct PixelFont {
    // Each glyph is 5 rows of 3 bools
    static let glyphs: [Character: [[Bool]]] = {
        let t = true, f = false
        return [
            "A": [[f,t,f],[t,f,t],[t,t,t],[t,f,t],[t,f,t]],
            "B": [[t,t,f],[t,f,t],[t,t,f],[t,f,t],[t,t,f]],
            "C": [[f,t,t],[t,f,f],[t,f,f],[t,f,f],[f,t,t]],
            "D": [[t,t,f],[t,f,t],[t,f,t],[t,f,t],[t,t,f]],
            "E": [[t,t,t],[t,f,f],[t,t,f],[t,f,f],[t,t,t]],
            "F": [[t,t,t],[t,f,f],[t,t,f],[t,f,f],[t,f,f]],
            "G": [[f,t,t],[t,f,f],[t,f,t],[t,f,t],[f,t,t]],
            "H": [[t,f,t],[t,f,t],[t,t,t],[t,f,t],[t,f,t]],
            "I": [[t,t,t],[f,t,f],[f,t,f],[f,t,f],[t,t,t]],
            "J": [[f,f,t],[f,f,t],[f,f,t],[t,f,t],[f,t,f]],
            "K": [[t,f,t],[t,f,t],[t,t,f],[t,f,t],[t,f,t]],
            "L": [[t,f,f],[t,f,f],[t,f,f],[t,f,f],[t,t,t]],
            "M": [[t,f,t],[t,t,t],[t,t,t],[t,f,t],[t,f,t]],
            "N": [[t,f,t],[t,t,t],[t,t,t],[t,t,t],[t,f,t]],
            "O": [[f,t,f],[t,f,t],[t,f,t],[t,f,t],[f,t,f]],
            "P": [[t,t,f],[t,f,t],[t,t,f],[t,f,f],[t,f,f]],
            "Q": [[f,t,f],[t,f,t],[t,f,t],[t,t,f],[f,t,t]],
            "R": [[t,t,f],[t,f,t],[t,t,f],[t,f,t],[t,f,t]],
            "S": [[f,t,t],[t,f,f],[f,t,f],[f,f,t],[t,t,f]],
            "T": [[t,t,t],[f,t,f],[f,t,f],[f,t,f],[f,t,f]],
            "U": [[t,f,t],[t,f,t],[t,f,t],[t,f,t],[f,t,f]],
            "V": [[t,f,t],[t,f,t],[t,f,t],[t,f,t],[f,t,f]],
            "W": [[t,f,t],[t,f,t],[t,t,t],[t,t,t],[t,f,t]],
            "X": [[t,f,t],[t,f,t],[f,t,f],[t,f,t],[t,f,t]],
            "Y": [[t,f,t],[t,f,t],[f,t,f],[f,t,f],[f,t,f]],
            "Z": [[t,t,t],[f,f,t],[f,t,f],[t,f,f],[t,t,t]],
            "0": [[f,t,f],[t,f,t],[t,f,t],[t,f,t],[f,t,f]],
            "1": [[f,t,f],[t,t,f],[f,t,f],[f,t,f],[t,t,t]],
            "2": [[t,t,f],[f,f,t],[f,t,f],[t,f,f],[t,t,t]],
            "3": [[t,t,f],[f,f,t],[f,t,f],[f,f,t],[t,t,f]],
            "4": [[t,f,t],[t,f,t],[t,t,t],[f,f,t],[f,f,t]],
            "5": [[t,t,t],[t,f,f],[t,t,f],[f,f,t],[t,t,f]],
            "6": [[f,t,t],[t,f,f],[t,t,f],[t,f,t],[f,t,f]],
            "7": [[t,t,t],[f,f,t],[f,t,f],[f,t,f],[f,t,f]],
            "8": [[f,t,f],[t,f,t],[f,t,f],[t,f,t],[f,t,f]],
            "9": [[f,t,f],[t,f,t],[f,t,t],[f,f,t],[t,t,f]],
            ".": [[f,f,f],[f,f,f],[f,f,f],[f,f,f],[f,t,f]],
            "-": [[f,f,f],[f,f,f],[t,t,t],[f,f,f],[f,f,f]],
            "!": [[f,t,f],[f,t,f],[f,t,f],[f,f,f],[f,t,f]],
            "?": [[t,t,f],[f,f,t],[f,t,f],[f,f,f],[f,t,f]],
            " ": [[f,f,f],[f,f,f],[f,f,f],[f,f,f],[f,f,f]],
        ]
    }()

    /// Render a string into a pixel grid
    static func render(_ text: String) -> [[Bool]] {
        let upper = text.uppercased()
        let charGrids = upper.map { glyphs[$0] ?? glyphs["?"]! }

        guard !charGrids.isEmpty else { return [] }

        let charW = 3
        let charH = 5
        let spacing = 1 // 1 pixel gap between chars
        let totalW = charGrids.count * (charW + spacing) - spacing

        var result = Array(repeating: Array(repeating: false, count: totalW), count: charH)
        for (ci, glyph) in charGrids.enumerated() {
            let xOff = ci * (charW + spacing)
            for row in 0..<charH {
                for col in 0..<charW {
                    result[row][xOff + col] = glyph[row][col]
                }
            }
        }
        return result
    }
}

// MARK: - Pixel Art Renderer

struct PixelArtView: View {
    let pixels: [[Bool]]
    let color: Color
    let pixelSize: CGFloat

    var body: some View {
        let rows = pixels.count
        let cols = pixels.first?.count ?? 0

        Canvas { context, _ in
            for row in 0..<rows {
                for col in 0..<cols {
                    if pixels[row][col] {
                        let rect = CGRect(
                            x: CGFloat(col) * pixelSize,
                            y: CGFloat(row) * pixelSize,
                            width: pixelSize,
                            height: pixelSize
                        )
                        context.fill(Path(rect), with: .color(color))
                    }
                }
            }
        }
        .frame(width: CGFloat(cols) * pixelSize, height: CGFloat(rows) * pixelSize)
    }
}

// MARK: - Theme-Aware Name Tag

struct NameTagView: View {
    let name: String
    let color: Color
    let theme: ChartTheme

    var body: some View {
        if theme.usePixelFont {
            pixelNameTag
        } else {
            systemNameTag
        }
    }

    // -- Pixel-font name tag (8-Bit theme) --
    private var pixelNameTag: some View {
        let nameGrid = PixelFont.render(name)
        let pixelSize = theme.pixelFontSize
        let textW = CGFloat(nameGrid.first?.count ?? 1) * pixelSize + 8
        let textH = CGFloat(nameGrid.count) * pixelSize + 6

        return ZStack {
            borderShape
                .fill(theme.backgroundColor.opacity(theme.tagBgOpacity))
                .overlay(borderShape.stroke(color, lineWidth: theme.tagBorderWidth))
                .frame(width: textW, height: textH)
                .shadow(color: color.opacity(0.5), radius: theme.tagGlowRadius)

            PixelArtView(pixels: nameGrid, color: color, pixelSize: pixelSize)
                .shadow(color: color.opacity(theme.tagGlowRadius > 0 ? 0.7 : 0), radius: 2)
        }
    }

    // -- System-font name tag (Victorian, Chalkboard, Corporate) --
    private var systemNameTag: some View {
        Text(name.uppercased())
            .font(theme.font(size: 10, weight: .bold))
            .foregroundStyle(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(
                borderShape
                    .fill(theme.backgroundColor.opacity(theme.tagBgOpacity))
            )
            .overlay(borderShape.stroke(color, lineWidth: theme.tagBorderWidth))
            .shadow(color: color.opacity(0.3), radius: theme.tagGlowRadius)
    }

    private var borderShape: AnyShape {
        if theme.squareBorders {
            AnyShape(Rectangle())
        } else {
            AnyShape(RoundedRectangle(cornerRadius: 4))
        }
    }
}

// iOS 16 / macOS 13 compatible type-erased shape
struct AnyShape: Shape, @unchecked Sendable {
    private let pathBuilder: @Sendable (CGRect) -> Path
    init<S: Shape>(_ shape: S) {
        pathBuilder = { shape.path(in: $0) }
    }
    func path(in rect: CGRect) -> Path {
        pathBuilder(rect)
    }
}

// MARK: - Person Marker View (Interactive)

struct PersonMarkerView: View {
    let person: Person
    let index: Int
    let chartSize: CGSize
    let chartPadding: CGFloat
    let theme: ChartTheme
    let onPositionChange: (CGPoint) -> Void

    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false

    private var drawableSize: CGSize {
        CGSize(
            width: chartSize.width - chartPadding * 2,
            height: chartSize.height - chartPadding * 2
        )
    }

    /// Pixel position of the snap dot (on the curve)
    private var snapPosition: CGPoint {
        CGPoint(
            x: chartPadding + person.position.x * drawableSize.width,
            y: chartPadding + (1 - person.position.y) * drawableSize.height
        )
    }

    /// Pixel position of the name tag (offset from curve)
    private var tagPosition: CGPoint {
        CGPoint(
            x: snapPosition.x,
            y: snapPosition.y - person.tagOffset * drawableSize.height
        )
    }

    /// Current display position — follows finger during drag, snapped position otherwise
    private var dotDisplayPosition: CGPoint {
        CGPoint(
            x: snapPosition.x + dragOffset.width,
            y: snapPosition.y + dragOffset.height
        )
    }

    private var tagDisplayPosition: CGPoint {
        CGPoint(
            x: tagPosition.x + dragOffset.width,
            y: tagPosition.y + dragOffset.height
        )
    }

    private var markerColor: Color {
        person.color(in: theme)
    }

    var body: some View {
        ZStack {
            // Snap dot on the curve
            Circle()
                .fill(markerColor)
                .frame(width: 8, height: 8)
                .shadow(color: markerColor.opacity(theme.tagGlowRadius > 0 ? 0.6 : 0.3), radius: 3)
                .position(dotDisplayPosition)

            // Leader line from snap dot to tag (if offset and not dragging)
            if abs(person.tagOffset) > 0.01 && !isDragging {
                Path { path in
                    path.move(to: dotDisplayPosition)
                    path.addLine(to: tagDisplayPosition)
                }
                .stroke(
                    markerColor.opacity(0.5),
                    style: StrokeStyle(lineWidth: 1, dash: [3, 2])
                )
            }

            // Name tag
            NameTagView(
                name: person.name,
                color: markerColor,
                theme: theme
            )
            .position(dotDisplayPosition) // tag follows dot during drag
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: person.position.x)
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: person.position.y)
        .gesture(
            DragGesture()
                .onChanged { value in
                    isDragging = true
                    // Free drag — follows finger in both X and Y
                    dragOffset = value.translation
                }
                .onEnded { value in
                    // Calculate where the finger ended up in normalized coords
                    let finalPixelX = snapPosition.x + value.translation.width
                    let finalPixelY = snapPosition.y + value.translation.height
                    let normX = (finalPixelX - chartPadding) / drawableSize.width
                    let normY = 1 - (finalPixelY - chartPadding) / drawableSize.height

                    // Reset drag offset immediately — the spring animation on
                    // person.position handles the visual snap to the curve
                    dragOffset = .zero
                    isDragging = false

                    // VM will clamp X and snap Y to the curve
                    onPositionChange(CGPoint(x: normX, y: normY))
                }
        )
    }
}

// MARK: - Static Marker (for export)

struct StaticMarkerView: View {
    let person: Person
    let theme: ChartTheme
    let chartPadding: CGFloat
    let drawW: CGFloat
    let drawH: CGFloat

    private var markerColor: Color {
        person.color(in: theme)
    }

    private var snapPos: CGPoint {
        CGPoint(
            x: chartPadding + person.position.x * drawW,
            y: chartPadding + (1 - person.position.y) * drawH
        )
    }

    private var tagPos: CGPoint {
        CGPoint(
            x: snapPos.x,
            y: snapPos.y - person.tagOffset * drawH
        )
    }

    var body: some View {
        ZStack {
            // Snap dot
            Circle()
                .fill(markerColor)
                .frame(width: 8, height: 8)
                .position(snapPos)

            // Leader line
            if abs(person.tagOffset) > 0.01 {
                Path { path in
                    path.move(to: snapPos)
                    path.addLine(to: tagPos)
                }
                .stroke(markerColor.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [3, 2]))
            }

            // Name tag
            NameTagView(
                name: person.name,
                color: markerColor,
                theme: theme
            )
            .position(tagPos)
        }
    }
}
