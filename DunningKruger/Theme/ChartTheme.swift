import SwiftUI

// MARK: - Theme Identifier

enum ThemeID: String, CaseIterable, Identifiable {
    case zxSpectrum  = "8-BIT"
    case victorian   = "VICTORIAN"
    case chalkboard  = "CHALKBOARD"
    case corporate   = "CORPORATE"
    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .zxSpectrum:  return "👾"
        case .victorian:   return "🏛"
        case .chalkboard:  return "🍎"
        case .corporate:   return "📊"
        }
    }

    var tagline: String {
        switch self {
        case .zxSpectrum:  return "Loading tape…"
        case .victorian:   return "Ye olde chart"
        case .chalkboard:  return "Class is in session"
        case .corporate:   return "Per my last email"
        }
    }

    var displayName: String {
        "\(emoji) \(rawValue)"
    }
}

enum ThemeOverlay {
    case none
    case crtScanlines
}

// MARK: - Chart Theme

struct ChartTheme {
    let id: ThemeID
    let titleText: String
    let exportTitleText: String

    // -- Colors --
    let backgroundColor: Color
    let gridLineColor: Color
    let curveColor: Color
    let curveGlowColor: Color?   // nil = no glow layer
    let titleColor: Color
    let axisLabelColor: Color
    let phaseLabelColor: Color
    let inputBgColor: Color
    let inputBorderColor: Color
    let buttonBgColor: Color
    let buttonTextColor: Color
    let chipBgColor: Color
    let markerColors: [Color]

    // -- Curve rendering --
    let curveLineWidth: CGFloat
    let curveGlowWidth: CGFloat
    let curveGlowBlur: CGFloat

    // -- Typography --
    let fontDesign: Font.Design
    let fontWeight: Font.Weight

    // -- Name tags --
    let usePixelFont: Bool
    let pixelFontSize: CGFloat
    let tagGlowRadius: CGFloat
    let tagBorderWidth: CGFloat
    let tagBgOpacity: Double

    // -- UI chrome --
    let squareBorders: Bool
    let bracketButtons: Bool
    let promptChar: String
    let borderWidth: CGFloat
    let overlay: ThemeOverlay

    // -- Helpers --

    func font(size: CGFloat, weight: Font.Weight? = nil) -> Font {
        .system(size: size, weight: weight ?? fontWeight, design: fontDesign)
    }

    func markerColor(at index: Int) -> Color {
        markerColors[index % markerColors.count]
    }

    var addText: String { bracketButtons ? "[ADD]" : "Add" }
    var shareText: String { bracketButtons ? "[SHARE]" : "Share" }
    var removeText: String { bracketButtons ? "[X]" : "\u{00D7}" }
}

// MARK: - The Four Themes

extension ChartTheme {

    // ── 8-Bit ZX Spectrum ────────────────────────────────────────
    static let zxSpectrum = ChartTheme(
        id: .zxSpectrum,
        titleText: "DUNNING-KREUGERIZER-5000",
        exportTitleText: "\u{26A1} DUNNING-KREUGERIZER-5000 \u{26A1}",
        backgroundColor:   Color(red: 0.05, green: 0.05, blue: 0.12),
        gridLineColor:     Color(red: 0.15, green: 0.15, blue: 0.25),
        curveColor:        Color(red: 0.0, green: 1.0, blue: 0.0),
        curveGlowColor:    Color(red: 0.0, green: 1.0, blue: 0.0).opacity(0.3),
        titleColor:        Color(red: 1.0, green: 1.0, blue: 0.0),
        axisLabelColor:    Color(red: 0.0, green: 0.8, blue: 0.8),
        phaseLabelColor:   Color(red: 0.7, green: 0.7, blue: 0.7),
        inputBgColor:      Color(red: 0.1, green: 0.1, blue: 0.2),
        inputBorderColor:  Color(red: 0.0, green: 0.8, blue: 0.8),
        buttonBgColor:     Color(red: 0.8, green: 0.0, blue: 0.0),
        buttonTextColor:   .white,
        chipBgColor:       Color(red: 0.12, green: 0.12, blue: 0.22),
        markerColors: [
            Color(red: 1.0, green: 0.0, blue: 0.0),
            Color(red: 0.3, green: 0.5, blue: 1.0),
            Color(red: 1.0, green: 0.0, blue: 1.0),
            Color(red: 0.0, green: 1.0, blue: 1.0),
            Color(red: 1.0, green: 1.0, blue: 0.0),
            Color(red: 1.0, green: 1.0, blue: 1.0),
            Color(red: 0.0, green: 1.0, blue: 0.0),
            Color(red: 1.0, green: 0.5, blue: 0.0),
        ],
        curveLineWidth: 3,
        curveGlowWidth: 8,
        curveGlowBlur: 4,
        fontDesign: .monospaced,
        fontWeight: .heavy,
        usePixelFont: true,
        pixelFontSize: 3.0,
        tagGlowRadius: 6,
        tagBorderWidth: 2,
        tagBgOpacity: 0.92,
        squareBorders: true,
        bracketButtons: true,
        promptChar: ">",
        borderWidth: 2,
        overlay: .crtScanlines
    )

    // ── Victorian Antique ────────────────────────────────────────
    static let victorian = ChartTheme(
        id: .victorian,
        titleText: "\u{2767} The Dunning-Kruger Effect \u{2766}",
        exportTitleText: "\u{2726} The Dunning-Kruger Effect \u{2726}",
        backgroundColor:   Color(red: 0.92, green: 0.87, blue: 0.76),      // warm aged parchment
        gridLineColor:     Color(red: 0.72, green: 0.62, blue: 0.48),      // visible antique grid
        curveColor:        Color(red: 0.35, green: 0.12, blue: 0.08),      // dark burgundy ink
        curveGlowColor:    nil,
        titleColor:        Color(red: 0.55, green: 0.38, blue: 0.08),      // antique gold
        axisLabelColor:    Color(red: 0.45, green: 0.30, blue: 0.12),      // warm brown-gold
        phaseLabelColor:   Color(red: 0.42, green: 0.28, blue: 0.14),      // rich brown
        inputBgColor:      Color(red: 0.88, green: 0.82, blue: 0.70),      // aged paper
        inputBorderColor:  Color(red: 0.58, green: 0.42, blue: 0.18),      // tarnished gold
        buttonBgColor:     Color(red: 0.50, green: 0.10, blue: 0.12),      // deep wine/burgundy
        buttonTextColor:   Color(red: 0.95, green: 0.88, blue: 0.65),      // gold text
        chipBgColor:       Color(red: 0.85, green: 0.78, blue: 0.64),      // faded parchment
        markerColors: [
            Color(red: 0.65, green: 0.10, blue: 0.10),   // crimson
            Color(red: 0.10, green: 0.22, blue: 0.55),   // royal blue
            Color(red: 0.55, green: 0.15, blue: 0.50),   // plum
            Color(red: 0.08, green: 0.42, blue: 0.30),   // emerald
            Color(red: 0.62, green: 0.48, blue: 0.05),   // old gold
            Color(red: 0.55, green: 0.20, blue: 0.08),   // burnt sienna
            Color(red: 0.28, green: 0.15, blue: 0.48),   // royal purple
            Color(red: 0.10, green: 0.38, blue: 0.45),   // teal
        ],
        curveLineWidth: 3.0,
        curveGlowWidth: 0,
        curveGlowBlur: 0,
        fontDesign: .serif,
        fontWeight: .bold,
        usePixelFont: false,
        pixelFontSize: 3.0,
        tagGlowRadius: 0,
        tagBorderWidth: 2.0,
        tagBgOpacity: 0.90,
        squareBorders: false,
        bracketButtons: false,
        promptChar: "\u{2767}",
        borderWidth: 2.5,
        overlay: .none
    )

    // ── Chalkboard ───────────────────────────────────────────────
    static let chalkboard = ChartTheme(
        id: .chalkboard,
        titleText: "The Dunning-Kruger Effect",
        exportTitleText: "The Dunning-Kruger Effect",
        backgroundColor:   Color(red: 0.14, green: 0.27, blue: 0.17),
        gridLineColor:     Color.white.opacity(0.12),
        curveColor:        Color.white.opacity(0.88),
        curveGlowColor:    nil,
        titleColor:        Color.white.opacity(0.92),
        axisLabelColor:    Color(red: 0.95, green: 0.85, blue: 0.50),
        phaseLabelColor:   Color.white.opacity(0.65),
        inputBgColor:      Color(red: 0.11, green: 0.22, blue: 0.14),
        inputBorderColor:  Color.white.opacity(0.35),
        buttonBgColor:     Color(red: 0.85, green: 0.55, blue: 0.55),
        buttonTextColor:   Color(red: 0.14, green: 0.27, blue: 0.17),
        chipBgColor:       Color(red: 0.17, green: 0.32, blue: 0.21),
        markerColors: [
            Color(red: 1.0, green: 0.85, blue: 0.40),
            Color(red: 0.55, green: 0.80, blue: 1.0),
            Color(red: 1.0, green: 0.60, blue: 0.65),
            Color.white,
            Color(red: 0.70, green: 1.0, blue: 0.65),
            Color(red: 1.0, green: 0.75, blue: 0.50),
            Color(red: 0.80, green: 0.65, blue: 1.0),
            Color(red: 0.60, green: 0.95, blue: 0.90),
        ],
        curveLineWidth: 3.5,
        curveGlowWidth: 0,
        curveGlowBlur: 0,
        fontDesign: .rounded,
        fontWeight: .semibold,
        usePixelFont: false,
        pixelFontSize: 3.0,
        tagGlowRadius: 0,
        tagBorderWidth: 1.5,
        tagBgOpacity: 0.85,
        squareBorders: false,
        bracketButtons: false,
        promptChar: "\u{270E}",
        borderWidth: 2,
        overlay: .none
    )

    // ── Corporate Slide ──────────────────────────────────────────
    static let corporate = ChartTheme(
        id: .corporate,
        titleText: "Competency Assessment Matrix",
        exportTitleText: "Competency Assessment Matrix",
        backgroundColor:   Color(red: 0.97, green: 0.97, blue: 0.98),
        gridLineColor:     Color(red: 0.88, green: 0.88, blue: 0.90),
        curveColor:        Color(red: 0.20, green: 0.40, blue: 0.75),
        curveGlowColor:    nil,
        titleColor:        Color(red: 0.20, green: 0.20, blue: 0.28),
        axisLabelColor:    Color(red: 0.45, green: 0.45, blue: 0.52),
        phaseLabelColor:   Color(red: 0.55, green: 0.55, blue: 0.62),
        inputBgColor:      Color.white,
        inputBorderColor:  Color(red: 0.80, green: 0.80, blue: 0.84),
        buttonBgColor:     Color(red: 0.20, green: 0.40, blue: 0.75),
        buttonTextColor:   .white,
        chipBgColor:       Color(red: 0.94, green: 0.94, blue: 0.96),
        markerColors: [
            Color(red: 0.20, green: 0.40, blue: 0.75),
            Color(red: 0.90, green: 0.35, blue: 0.25),
            Color(red: 0.20, green: 0.65, blue: 0.35),
            Color(red: 0.95, green: 0.65, blue: 0.10),
            Color(red: 0.55, green: 0.30, blue: 0.70),
            Color(red: 0.15, green: 0.55, blue: 0.55),
            Color(red: 0.85, green: 0.45, blue: 0.15),
            Color(red: 0.50, green: 0.50, blue: 0.55),
        ],
        curveLineWidth: 2.5,
        curveGlowWidth: 0,
        curveGlowBlur: 0,
        fontDesign: .default,
        fontWeight: .semibold,
        usePixelFont: false,
        pixelFontSize: 3.0,
        tagGlowRadius: 0,
        tagBorderWidth: 1,
        tagBgOpacity: 0.95,
        squareBorders: false,
        bracketButtons: false,
        promptChar: "\u{2022}",
        borderWidth: 1,
        overlay: .none
    )

    // -- Factory --
    static func theme(for id: ThemeID) -> ChartTheme {
        switch id {
        case .zxSpectrum:  return .zxSpectrum
        case .victorian:   return .victorian
        case .chalkboard:  return .chalkboard
        case .corporate:   return .corporate
        }
    }
}
