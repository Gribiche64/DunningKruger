import SwiftUI

@MainActor
class ThemeManager: ObservableObject {
    @Published var selectedThemeID: ThemeID = .zxSpectrum

    var theme: ChartTheme {
        ChartTheme.theme(for: selectedThemeID)
    }
}
