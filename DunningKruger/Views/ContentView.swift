import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ChartViewModel()
    @EnvironmentObject var themeManager: ThemeManager
    @State private var newName = ""

    private var theme: ChartTheme { themeManager.theme }

    var body: some View {
        ZStack {
            // Background
            theme.backgroundColor.ignoresSafeArea()

            VStack(spacing: 10) {
                // Title + Theme picker row
                HStack {
                    Spacer()

                    Text(theme.titleText)
                        .font(theme.font(size: 16, weight: .heavy))
                        .foregroundStyle(theme.titleColor)
                        .shadow(color: theme.titleColor.opacity(0.8), radius: theme.tagGlowRadius > 0 ? 6 : 0)
                        .shadow(color: theme.titleColor.opacity(0.4), radius: theme.tagGlowRadius > 0 ? 12 : 0)

                    Spacer()

                    // Theme picker
                    Menu {
                        ForEach(ThemeID.allCases) { tid in
                            Button {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    themeManager.selectedThemeID = tid
                                }
                            } label: {
                                let selected = themeManager.selectedThemeID == tid
                                Label {
                                    VStack(alignment: .leading) {
                                        Text(tid.displayName)
                                        Text(tid.tagline)
                                    }
                                } icon: {
                                    if selected {
                                        Image(systemName: "checkmark.circle.fill")
                                    } else {
                                        Image(systemName: "circle")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(themeManager.selectedThemeID.emoji)
                                .font(.system(size: 14))
                            Image(systemName: "paintbrush.pointed.fill")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(theme.curveColor)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundStyle(theme.axisLabelColor)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(theme.chipBgColor)
                        .overlay(
                            Group {
                                if theme.squareBorders {
                                    Rectangle().stroke(theme.inputBorderColor, lineWidth: theme.borderWidth)
                                } else {
                                    RoundedRectangle(cornerRadius: 4).stroke(theme.inputBorderColor, lineWidth: theme.borderWidth)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)

                // Input row
                HStack(spacing: 6) {
                    Text(theme.promptChar)
                        .font(theme.font(size: 16, weight: .bold))
                        .foregroundStyle(theme.curveColor)

                    TextField("ENTER NAME", text: $newName)
                        .textFieldStyle(.plain)
                        .font(theme.font(size: 16, weight: .semibold))
                        .foregroundStyle(theme.titleColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(theme.inputBgColor)
                        .overlay(
                            Group {
                                if theme.squareBorders {
                                    Rectangle().stroke(theme.inputBorderColor, lineWidth: theme.borderWidth)
                                } else {
                                    RoundedRectangle(cornerRadius: 4).stroke(theme.inputBorderColor, lineWidth: theme.borderWidth)
                                }
                            }
                        )
                        #if os(iOS)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.words)
                        #endif
                        .onSubmit { addPerson() }

                    Button {
                        addPerson()
                    } label: {
                        Text(theme.addText)
                            .font(theme.font(size: 14, weight: .heavy))
                            .foregroundStyle(theme.buttonTextColor)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                newName.trimmingCharacters(in: .whitespaces).isEmpty
                                    ? Color.gray.opacity(0.3)
                                    : theme.buttonBgColor
                            )
                            .overlay(
                                Group {
                                    if theme.squareBorders {
                                        Rectangle().stroke(Color.white.opacity(0.4), lineWidth: theme.borderWidth)
                                    } else {
                                        RoundedRectangle(cornerRadius: 4).stroke(Color.white.opacity(0.4), lineWidth: 1)
                                    }
                                }
                            )
                    }
                    .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.horizontal)

                // Chart
                ChartView(viewModel: viewModel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 8)

                // Bottom bar — fixed height so chart doesn't resize when chips appear
                HStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(viewModel.people) { person in
                                PersonChip(person: person, theme: theme) {
                                    viewModel.removePerson(person)
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }

                    Spacer()

                    ShareButton(viewModel: viewModel, theme: theme)
                        .opacity(viewModel.people.isEmpty ? 0 : 1)
                }
                .frame(height: 32)
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
        }
        #if os(macOS)
        .frame(minWidth: 700, minHeight: 500)
        #endif
    }

    private func addPerson() {
        viewModel.addPerson(named: newName)
        newName = ""
    }
}

// MARK: - Person Chip (theme-aware)

struct PersonChip: View {
    let person: Person
    let theme: ChartTheme
    let onRemove: () -> Void

    private var chipColor: Color { person.color(in: theme) }

    var body: some View {
        HStack(spacing: 4) {
            // Tiny color swatch
            Canvas { context, _ in
                let p = CGFloat(3)
                for r in 0..<3 {
                    for c in 0..<3 {
                        let isBorder = r == 0 || r == 2 || c == 0 || c == 2
                        let rect = CGRect(x: CGFloat(c) * p, y: CGFloat(r) * p, width: p, height: p)
                        context.fill(Path(rect), with: .color(chipColor.opacity(isBorder ? 0.5 : 1.0)))
                    }
                }
            }
            .frame(width: 9, height: 9)

            Text(person.name.uppercased())
                .font(theme.font(size: 10, weight: .heavy))
                .foregroundStyle(chipColor)
                .lineLimit(1)

            Button {
                onRemove()
            } label: {
                Text(theme.removeText)
                    .font(theme.font(size: 9, weight: .heavy))
                    .foregroundStyle(theme.buttonBgColor)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(theme.chipBgColor)
        .overlay(
            Group {
                if theme.squareBorders {
                    Rectangle().stroke(chipColor.opacity(0.5), lineWidth: theme.borderWidth)
                } else {
                    RoundedRectangle(cornerRadius: 4).stroke(chipColor.opacity(0.5), lineWidth: 1)
                }
            }
        )
    }
}

// MARK: - Share Button (theme-aware)

struct ShareButton: View {
    @ObservedObject var viewModel: ChartViewModel
    let theme: ChartTheme

    var body: some View {
        Button {
            shareChart()
        } label: {
            Text(theme.shareText)
                .font(theme.font(size: 12, weight: .heavy))
                .foregroundStyle(theme.axisLabelColor)
                .shadow(color: theme.axisLabelColor.opacity(0.5), radius: theme.tagGlowRadius > 0 ? 3 : 0)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(theme.chipBgColor)
                .overlay(
                    Group {
                        if theme.squareBorders {
                            Rectangle().stroke(theme.inputBorderColor, lineWidth: theme.borderWidth)
                        } else {
                            RoundedRectangle(cornerRadius: 4).stroke(theme.inputBorderColor, lineWidth: 1)
                        }
                    }
                )
        }
        .buttonStyle(.plain)
    }

    @MainActor
    private func shareChart() {
        let chartView = StaticChartView(people: viewModel.people, theme: theme)
            .frame(width: 800, height: 500)

        let renderer = ImageRenderer(content: chartView)
        renderer.scale = 2.0

        #if os(iOS)
        guard let uiImage = renderer.uiImage else { return }

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else { return }

        let activityVC = UIActivityViewController(activityItems: [uiImage], applicationActivities: nil)

        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = rootVC.view
            popover.sourceRect = CGRect(x: rootVC.view.bounds.midX, y: rootVC.view.bounds.maxY - 50, width: 0, height: 0)
        }

        rootVC.present(activityVC, animated: true)

        #else
        guard let cgImage = renderer.cgImage else { return }
        let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width / 2, height: cgImage.height / 2))

        // Write a temp PNG file so share sheet services (Messages, Mail, AirDrop) get a real file
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("Kreugerizer5000.png")
        let rep = NSBitmapImageRep(cgImage: cgImage)
        if let data = rep.representation(using: .png, properties: [:]) {
            try? data.write(to: tempURL)
        }

        // Show native macOS share picker (AirDrop, Messages, Mail, Save, etc.)
        guard let window = NSApplication.shared.keyWindow,
              let contentView = window.contentView else { return }

        let picker = NSSharingServicePicker(items: [nsImage, tempURL])
        // Anchor the picker to the bottom-right area where the share button is
        let buttonRect = CGRect(
            x: contentView.bounds.maxX - 100,
            y: 10,
            width: 1,
            height: 1
        )
        picker.show(relativeTo: buttonRect, of: contentView, preferredEdge: .maxY)
        #endif
    }
}
