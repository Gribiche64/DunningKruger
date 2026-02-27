import SwiftUI

@MainActor
class ChartViewModel: ObservableObject {
    @Published var people: [Person] = []
    @Published var toastMessage: String? = nil

    private var nextColorIndex: Int = 0
    private let sampler = DKCurveSampler.shared
    private var toastCounter = 0

    func addPerson(named name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        let colorIndex = nextColorIndex
        nextColorIndex += 1

        // Random X, snapped to curve for Y
        let randomX = CGFloat.random(in: 0.1...0.9)
        let snapped = sampler.snap(CGPoint(x: randomX, y: 0))

        let person = Person(
            name: trimmed,
            colorIndex: colorIndex,
            position: snapped
        )
        people.append(person)
        resolveOverlaps()
        showZoneToast(name: trimmed, x: snapped.x)
    }

    func removePerson(_ person: Person) {
        people.removeAll { $0.id == person.id }
        resolveOverlaps()
    }

    func updatePosition(for personID: UUID, to newPosition: CGPoint, aspectRatio: CGFloat = 1.0) {
        guard let index = people.firstIndex(where: { $0.id == personID }) else { return }
        // Find the closest point on the curve (shortest pixel distance)
        people[index].position = sampler.nearestPoint(to: newPosition, aspectRatio: aspectRatio)
        resolveOverlaps()
        showZoneToast(name: people[index].name, x: people[index].position.x)
    }

    func randomizeAll() {
        for i in people.indices {
            let randomX = CGFloat.random(in: 0.1...0.9)
            people[i].position = sampler.snap(CGPoint(x: randomX, y: 0))
        }
        resolveOverlaps()
    }

    // MARK: - Zone Detection & Toast

    static func zoneName(forX x: CGFloat) -> String {
        if x < 0.22 { return "Mt. Stupid" }
        if x < 0.48 { return "the Valley of Despair" }
        if x < 0.70 { return "the Slope of Enlightenment" }
        return "the Plateau of Sustainability"
    }

    /// Position-aware message aligned to the actual curve geometry.
    /// Peak of Mt. Stupid = x 0.15, Valley bottom = x 0.40, Plateau starts = x 0.70.
    private static func toastText(name: String, x: CGFloat) -> String {
        switch x {
        // ── Mt. Stupid (peak at x ≈ 0.15) ──
        case ..<0.06:
            return "\(name) is at the base of Mt. Stupid"
        case ..<0.12:
            return "\(name) is scaling Mt. Stupid"
        case ..<0.17:
            return "\(name) is at the peak of Mt. Stupid"
        case ..<0.22:
            return "\(name) is coming down from Mt. Stupid"

        // ── Valley of Despair (bottom at x ≈ 0.40) ──
        case ..<0.28:
            return "\(name) is descending into the Valley of Despair"
        case ..<0.35:
            return "\(name) is deep in the Valley of Despair"
        case ..<0.42:
            return "\(name) is at the bottom of the Valley of Despair"
        case ..<0.48:
            return "\(name) is climbing out of the Valley of Despair"

        // ── Slope of Enlightenment (x 0.48 → 0.70) ──
        case ..<0.55:
            return "\(name) has found the Slope of Enlightenment"
        case ..<0.63:
            return "\(name) is halfway up the Slope of Enlightenment"
        case ..<0.70:
            return "\(name) is nearing the top of the Slope of Enlightenment"

        // ── Plateau of Sustainability (x 0.70+) ──
        case ..<0.82:
            return "\(name) has reached the Plateau of Sustainability"
        default:
            return "\(name) is well into the Plateau of Sustainability"
        }
    }

    private func showZoneToast(name: String, x: CGFloat) {
        toastMessage = Self.toastText(name: name, x: x)
        toastCounter += 1
        let currentCount = toastCounter
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            if toastCounter == currentCount {
                toastMessage = nil
            }
        }
    }

    // MARK: - Tag Overlap Resolution

    private func resolveOverlaps() {
        guard !people.isEmpty else { return }

        let tags: [(index: Int, x: CGFloat, curveY: CGFloat, nameLength: Int)] =
            people.enumerated().map { i, p in
                (index: i, x: p.position.x, curveY: p.position.y, nameLength: p.name.count)
            }

        let offsets = TagLayoutEngine.resolveOverlaps(tags: tags)
        for i in people.indices {
            people[i].tagOffset = offsets[i]
        }
    }
}
