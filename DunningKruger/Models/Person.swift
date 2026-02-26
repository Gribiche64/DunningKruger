import SwiftUI

struct Person: Identifiable {
    let id = UUID()
    var name: String
    /// Index into the theme's markerColors array — resolved at render time
    var colorIndex: Int
    /// Normalized position within the chart area (0...1 on both axes)
    /// x = experience/knowledge, y = confidence (snapped to curve)
    var position: CGPoint
    /// Vertical offset for the name tag to avoid overlaps (normalized coords)
    var tagOffset: CGFloat = 0

    var initials: String {
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    /// Resolve color from theme at render time
    func color(in theme: ChartTheme) -> Color {
        theme.markerColor(at: colorIndex)
    }
}
