import SwiftUI

@MainActor
class ThemeManager: ObservableObject {
    @Published var selectedThemeID: ThemeID = ThemeID.allCases.randomElement() ?? .zxSpectrum

    var theme: ChartTheme {
        ChartTheme.theme(for: selectedThemeID)
    }
}
