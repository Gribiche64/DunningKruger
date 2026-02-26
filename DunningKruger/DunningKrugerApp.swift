import SwiftUI

@main
struct DunningKrugerApp: App {
    @StateObject private var themeManager = ThemeManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
        }
        #if os(macOS)
        .defaultSize(width: 800, height: 600)
        #endif
    }
}
