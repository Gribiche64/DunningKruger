import SwiftUI

struct SplashView: View {
    @EnvironmentObject var themeManager: ThemeManager

    @State private var progress: CGFloat = 0
    @State private var typedText = ""
    @State private var cursorVisible = true
    @State private var showLine1 = false
    @State private var showLine2 = false
    @State private var showLine3 = false
    @State private var spinAngle: Double = 0

    private var theme: ChartTheme { themeManager.theme }

    var body: some View {
        ZStack {
            theme.backgroundColor.ignoresSafeArea()

            switch themeManager.selectedThemeID {
            case .zxSpectrum:   zxSpectrumSplash
            case .victorian:    victorianSplash
            case .chalkboard:   chalkboardSplash
            case .corporate:    corporateSplash
            }
        }
        .onAppear { startAnimations() }
    }

    // MARK: - ZX Spectrum: tape loading with colored stripes

    private var zxSpectrumSplash: some View {
        ZStack {
            // Animated loading stripes (fills from top)
            Canvas { context, size in
                let colors: [Color] = [.red, .yellow, .green, .cyan, .blue, .purple]
                let stripeH: CGFloat = 3
                var y: CGFloat = 0
                var i = 0
                let maxY = size.height * progress
                while y < maxY {
                    let rect = CGRect(x: 0, y: y, width: size.width, height: stripeH)
                    context.fill(Path(rect), with: .color(colors[i % colors.count]))
                    y += stripeH
                    i += 1
                }
            }
            .ignoresSafeArea()
            .opacity(0.15)

            VStack(spacing: 16) {
                Spacer()

                // Header
                Text("SINCLAIR RESEARCH LTD")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color(red: 0.7, green: 0.7, blue: 0.7))

                Text("48K SYSTEM")
                    .font(.system(size: 10, weight: .regular, design: .monospaced))
                    .foregroundStyle(Color(red: 0.5, green: 0.5, blue: 0.5))

                Spacer()

                // Central typed text
                VStack(spacing: 8) {
                    Text("PROGRAM: KREUGERIZER-5000")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.white)

                    Text("BYTES: 48K")
                        .font(.system(size: 12, weight: .regular, design: .monospaced))
                        .foregroundStyle(Color(red: 0.0, green: 0.8, blue: 0.8))

                    HStack(spacing: 0) {
                        Text(typedText)
                            .font(.system(size: 16, weight: .heavy, design: .monospaced))
                            .foregroundStyle(Color(red: 1.0, green: 1.0, blue: 0.0))

                        Text(cursorVisible ? "\u{2588}" : " ")
                            .font(.system(size: 16, weight: .heavy, design: .monospaced))
                            .foregroundStyle(Color(red: 1.0, green: 1.0, blue: 0.0))
                    }
                }

                Spacer()

                // Progress bar
                VStack(spacing: 4) {
                    GeometryReader { geo in
                        let w = geo.size.width
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color(red: 0.15, green: 0.15, blue: 0.25))
                                .frame(height: 8)

                            Rectangle()
                                .fill(Color(red: 0.0, green: 1.0, blue: 0.0))
                                .frame(width: w * progress, height: 8)
                        }
                    }
                    .frame(height: 8)

                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color(red: 0.0, green: 1.0, blue: 0.0))
                }
                .padding(.horizontal, 60)
                .padding(.bottom, 50)
            }

            // CRT scanlines
            CRTScanlinesView()
                .allowsHitTesting(false)
                .ignoresSafeArea()
        }
    }

    // MARK: - Victorian: elegant text fade-in

    private var victorianSplash: some View {
        VStack(spacing: 24) {
            Spacer()

            // Ornamental divider
            Text("\u{2726} \u{2726} \u{2726}")
                .font(.system(size: 20, design: .serif))
                .foregroundStyle(theme.titleColor)
                .opacity(showLine1 ? 1 : 0)

            Text("Preparing the\nApparatus")
                .font(.system(size: 28, weight: .bold, design: .serif))
                .multilineTextAlignment(.center)
                .foregroundStyle(theme.titleColor)
                .opacity(showLine2 ? 1 : 0)

            // Ornamental flourish
            Text("\u{2767} \u{2022} \u{2766}")
                .font(.system(size: 18, design: .serif))
                .foregroundStyle(theme.axisLabelColor)
                .opacity(showLine2 ? 1 : 0)

            Text("— Anno Domini MMXXVI —")
                .font(.system(size: 12, weight: .regular, design: .serif))
                .italic()
                .foregroundStyle(theme.axisLabelColor.opacity(0.7))
                .opacity(showLine3 ? 1 : 0)

            Spacer()

            // Elegant line progress
            GeometryReader { geo in
                let w = geo.size.width
                VStack(spacing: 2) {
                    Rectangle()
                        .fill(theme.inputBorderColor.opacity(0.3))
                        .frame(height: 1)
                    Rectangle()
                        .fill(theme.curveColor)
                        .frame(width: w * progress, height: 2)
                    Rectangle()
                        .fill(theme.inputBorderColor.opacity(0.3))
                        .frame(height: 1)
                }
            }
            .frame(height: 6)
            .padding(.horizontal, 80)
            .padding(.bottom, 50)
        }
    }

    // MARK: - Chalkboard: chalk writing effect

    private var chalkboardSplash: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("\u{270E}")
                .font(.system(size: 40))
                .opacity(showLine1 ? 1 : 0)
                .scaleEffect(showLine1 ? 1.0 : 0.3)

            Text("Class is in session")
                .font(.system(size: 26, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.9))
                .opacity(showLine2 ? 1 : 0)

            Text("Please take your seats...")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(Color(red: 0.95, green: 0.85, blue: 0.50))
                .opacity(showLine3 ? 1 : 0)

            Spacer()

            // Chalk-like dotted progress
            GeometryReader { geo in
                let w = geo.size.width
                ZStack(alignment: .leading) {
                    // Chalk dust dots (background)
                    HStack(spacing: 4) {
                        ForEach(0..<30, id: \.self) { _ in
                            Circle()
                                .fill(Color.white.opacity(0.15))
                                .frame(width: 4, height: 4)
                        }
                    }

                    // Filled chalk dots
                    Rectangle()
                        .fill(Color.white.opacity(0.7))
                        .frame(width: w * progress, height: 3)
                        .mask(
                            HStack(spacing: 4) {
                                ForEach(0..<30, id: \.self) { _ in
                                    Circle()
                                        .frame(width: 4, height: 4)
                                }
                            }
                        )
                }
            }
            .frame(height: 6)
            .padding(.horizontal, 60)
            .padding(.bottom, 50)
        }
    }

    // MARK: - Corporate: boring spinner

    private var corporateSplash: some View {
        VStack(spacing: 20) {
            Spacer()

            // Spinning circle
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(theme.curveColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .frame(width: 36, height: 36)
                .rotationEffect(.degrees(spinAngle))

            Text("Synergizing competency matrices...")
                .font(.system(size: 14, weight: .medium, design: .default))
                .foregroundStyle(theme.axisLabelColor)
                .opacity(showLine1 ? 1 : 0)

            Text("Please do not adjust your KPIs.")
                .font(.system(size: 11, weight: .regular, design: .default))
                .foregroundStyle(theme.axisLabelColor.opacity(0.6))
                .opacity(showLine2 ? 1 : 0)

            Spacer()

            // Plain gray bar
            GeometryReader { geo in
                let w = geo.size.width
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(theme.curveColor)
                        .frame(width: w * progress, height: 4)
                }
            }
            .frame(height: 4)
            .padding(.horizontal, 80)
            .padding(.bottom, 50)
        }
    }

    // MARK: - Animations

    private func startAnimations() {
        // Progress bar: 0 → 1 over 1.5s
        withAnimation(.easeInOut(duration: 1.5)) {
            progress = 1.0
        }

        // Staggered text reveals
        withAnimation(.easeOut(duration: 0.4).delay(0.1)) { showLine1 = true }
        withAnimation(.easeOut(duration: 0.4).delay(0.4)) { showLine2 = true }
        withAnimation(.easeOut(duration: 0.4).delay(0.7)) { showLine3 = true }

        // Theme-specific animations
        switch themeManager.selectedThemeID {
        case .zxSpectrum:
            typeText("LOADING...", delay: 0.08)
            startCursorBlink()
        case .corporate:
            startSpinner()
        default:
            break
        }
    }

    private func typeText(_ text: String, delay: Double) {
        for (i, char) in text.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay * Double(i)) {
                typedText.append(char)
            }
        }
    }

    private func startCursorBlink() {
        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { timer in
            cursorVisible.toggle()
            // Stop blinking after splash is done
            if progress >= 1.0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    timer.invalidate()
                }
            }
        }
    }

    private func startSpinner() {
        withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
            spinAngle = 360
        }
    }
}
