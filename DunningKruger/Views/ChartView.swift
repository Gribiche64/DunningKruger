import SwiftUI

struct ChartView: View {
    @ObservedObject var viewModel: ChartViewModel
    @EnvironmentObject var themeManager: ThemeManager

    private var theme: ChartTheme { themeManager.theme }

    /// Responsive chart padding — smaller on compact screens
    private func chartPad(for size: CGSize) -> CGFloat {
        size.width < 500 ? 28 : 44
    }

    /// Responsive font size for phase labels
    private func phaseFontSize(for size: CGSize) -> CGFloat {
        size.width < 400 ? 9 : size.width < 600 ? 11 : 13
    }

    /// Responsive font size for axis labels
    private func axisFontSize(for size: CGSize) -> CGFloat {
        size.width < 400 ? 8 : size.width < 600 ? 10 : 11
    }

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let padding = chartPad(for: size)

            ZStack {
                // Background
                Group {
                    if theme.squareBorders {
                        Rectangle()
                            .fill(theme.backgroundColor)
                            .overlay(Rectangle().stroke(theme.inputBorderColor, lineWidth: theme.borderWidth))
                    } else {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(theme.backgroundColor)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(theme.inputBorderColor, lineWidth: theme.borderWidth)
                            )
                    }
                }

                // Grid
                RetroGridLines()
                    .stroke(theme.gridLineColor, lineWidth: 0.5)
                    .padding(padding)

                // Curve glow layer (if theme has glow)
                if let glowColor = theme.curveGlowColor {
                    DKCurveShape()
                        .stroke(
                            glowColor,
                            style: StrokeStyle(lineWidth: theme.curveGlowWidth, lineCap: .round, lineJoin: .round)
                        )
                        .blur(radius: theme.curveGlowBlur)
                        .padding(padding)
                }

                // Curve main line
                DKCurveShape()
                    .stroke(
                        theme.curveColor,
                        style: StrokeStyle(lineWidth: theme.curveLineWidth, lineCap: .round, lineJoin: .round)
                    )
                    .padding(padding)

                // Phase labels
                phaseLabels(in: size, padding: padding)

                // Axis labels
                axisLabels(in: size, padding: padding)

                // Overlay (CRT scanlines, etc.)
                if theme.overlay == .crtScanlines {
                    CRTScanlinesView()
                        .allowsHitTesting(false)
                }

                // People markers
                ForEach(Array(viewModel.people.enumerated()), id: \.element.id) { index, person in
                    PersonMarkerView(
                        person: person,
                        index: index,
                        chartSize: size,
                        chartPadding: padding,
                        theme: theme
                    ) { newPosition, aspectRatio in
                        viewModel.updatePosition(for: person.id, to: newPosition, aspectRatio: aspectRatio)
                    }
                    .transition(.scale(scale: 0.3).combined(with: .opacity))
                }
            }
            #if os(iOS)
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            #endif
        }
    }

    @ViewBuilder
    private func phaseLabels(in size: CGSize, padding: CGFloat) -> some View {
        let drawW = size.width - padding * 2
        let drawH = size.height - padding * 2
        let fontSize = phaseFontSize(for: size)

        ZStack {
            phaseLabel("MT. STUPID", fontSize: fontSize, x: padding + 0.18 * drawW, y: padding + 0.02 * drawH)
            phaseLabel("VALLEY OF\nDESPAIR", fontSize: fontSize, x: padding + 0.40 * drawW, y: padding + 0.97 * drawH)
            phaseLabel("SLOPE OF\nENLIGHTENMENT", fontSize: fontSize, x: padding + 0.62 * drawW, y: padding + 0.50 * drawH)
            phaseLabel("PLATEAU OF\nSUSTAINABILITY", fontSize: fontSize, x: padding + 0.88 * drawW, y: padding + 0.10 * drawH)
        }
    }

    private func phaseLabel(_ text: String, fontSize: CGFloat, x: CGFloat, y: CGFloat) -> some View {
        Text(text)
            .font(theme.font(size: fontSize, weight: .bold))
            .multilineTextAlignment(.center)
            .foregroundStyle(theme.phaseLabelColor)
            .shadow(color: theme.backgroundColor, radius: 4)
            .shadow(color: theme.backgroundColor, radius: 8)
            .position(x: x, y: y)
    }

    @ViewBuilder
    private func axisLabels(in size: CGSize, padding: CGFloat) -> some View {
        let axisSize = axisFontSize(for: size)

        Text("EXPERIENCE / KNOWLEDGE -->")
            .font(theme.font(size: axisSize, weight: .bold))
            .foregroundStyle(theme.axisLabelColor)
            .position(x: size.width / 2, y: size.height - 10)

        Text("CONFIDENCE -->")
            .font(theme.font(size: axisSize, weight: .bold))
            .foregroundStyle(theme.axisLabelColor)
            .rotationEffect(.degrees(-90))
            .fixedSize()
            .position(x: 12, y: size.height / 2)
    }
}

// MARK: - Static version for image export

struct StaticChartView: View {
    let people: [Person]
    let theme: ChartTheme
    private let chartPadding: CGFloat = 44

    private var dateString: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: Date())
    }

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let drawW = size.width - chartPadding * 2
            let drawH = size.height - chartPadding * 2

            ZStack {
                // Background
                Rectangle().fill(theme.backgroundColor)

                Group {
                    if theme.squareBorders {
                        Rectangle().stroke(theme.inputBorderColor, lineWidth: theme.borderWidth)
                    } else {
                        RoundedRectangle(cornerRadius: 4).stroke(theme.inputBorderColor, lineWidth: theme.borderWidth)
                    }
                }

                // Grid
                RetroGridLines()
                    .stroke(theme.gridLineColor, lineWidth: 0.5)
                    .padding(chartPadding)

                // Curve glow
                if let glowColor = theme.curveGlowColor {
                    DKCurveShape()
                        .stroke(glowColor, style: StrokeStyle(lineWidth: theme.curveGlowWidth, lineCap: .round, lineJoin: .round))
                        .blur(radius: theme.curveGlowBlur)
                        .padding(chartPadding)
                }

                // Curve
                DKCurveShape()
                    .stroke(theme.curveColor, style: StrokeStyle(lineWidth: theme.curveLineWidth, lineCap: .round, lineJoin: .round))
                    .padding(chartPadding)

                // Phase labels
                Text("MT. STUPID")
                    .font(theme.font(size: 13, weight: .bold))
                    .multilineTextAlignment(.center).foregroundStyle(theme.phaseLabelColor)
                    .shadow(color: theme.backgroundColor, radius: 4)
                    .shadow(color: theme.backgroundColor, radius: 8)
                    .position(x: chartPadding + 0.18 * drawW, y: chartPadding + 0.02 * drawH)

                Text("VALLEY OF\nDESPAIR")
                    .font(theme.font(size: 13, weight: .bold))
                    .multilineTextAlignment(.center).foregroundStyle(theme.phaseLabelColor)
                    .shadow(color: theme.backgroundColor, radius: 4)
                    .shadow(color: theme.backgroundColor, radius: 8)
                    .position(x: chartPadding + 0.40 * drawW, y: chartPadding + 0.97 * drawH)

                Text("SLOPE OF\nENLIGHTENMENT")
                    .font(theme.font(size: 13, weight: .bold))
                    .multilineTextAlignment(.center).foregroundStyle(theme.phaseLabelColor)
                    .shadow(color: theme.backgroundColor, radius: 4)
                    .shadow(color: theme.backgroundColor, radius: 8)
                    .position(x: chartPadding + 0.62 * drawW, y: chartPadding + 0.50 * drawH)

                Text("PLATEAU OF\nSUSTAINABILITY")
                    .font(theme.font(size: 13, weight: .bold))
                    .multilineTextAlignment(.center).foregroundStyle(theme.phaseLabelColor)
                    .shadow(color: theme.backgroundColor, radius: 4)
                    .shadow(color: theme.backgroundColor, radius: 8)
                    .position(x: chartPadding + 0.88 * drawW, y: chartPadding + 0.10 * drawH)

                // Axis labels
                Text("EXPERIENCE / KNOWLEDGE -->")
                    .font(theme.font(size: 11, weight: .bold))
                    .foregroundStyle(theme.axisLabelColor)
                    .position(x: size.width / 2, y: size.height - 10)

                Text("CONFIDENCE -->")
                    .font(theme.font(size: 11, weight: .bold))
                    .foregroundStyle(theme.axisLabelColor)
                    .rotationEffect(.degrees(-90)).fixedSize()
                    .position(x: 14, y: size.height / 2)

                // Title
                Text(theme.exportTitleText)
                    .font(theme.font(size: 13, weight: .bold))
                    .foregroundStyle(theme.titleColor)
                    .shadow(color: theme.titleColor.opacity(0.5), radius: 4)
                    .position(x: size.width / 2, y: 16)

                // Date watermark
                Text(dateString)
                    .font(theme.font(size: 9, weight: .regular))
                    .foregroundStyle(theme.axisLabelColor.opacity(0.5))
                    .position(x: size.width - 60, y: size.height - 10)

                // Static markers with snap dots + leader lines + name tags
                ForEach(people) { person in
                    StaticMarkerView(
                        person: person,
                        theme: theme,
                        chartPadding: chartPadding,
                        drawW: drawW,
                        drawH: drawH
                    )
                }

                // Overlay
                if theme.overlay == .crtScanlines {
                    CRTScanlinesView()
                        .allowsHitTesting(false)
                }
            }
        }
    }
}

// MARK: - CRT Scanlines Effect

struct CRTScanlinesView: View {
    var body: some View {
        Canvas { context, size in
            let lineSpacing: CGFloat = 3
            var y: CGFloat = 0
            while y < size.height {
                let rect = CGRect(x: 0, y: y, width: size.width, height: 1)
                context.fill(Path(rect), with: .color(.black.opacity(0.15)))
                y += lineSpacing
            }
        }
        .overlay(
            RadialGradient(
                colors: [.clear, .black.opacity(0.3)],
                center: .center,
                startRadius: 100,
                endRadius: 500
            )
            .blendMode(.multiply)
        )
    }
}
