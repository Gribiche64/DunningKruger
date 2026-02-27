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
        if x < 0.25 { return "Mt. Stupid" }
        if x < 0.48 { return "the Valley of Despair" }
        if x < 0.75 { return "the Slope of Enlightenment" }
        return "the Plateau of Sustainability"
    }

    /// Generates a position-aware quip. The curve is sliced into ~10 sub-zones
    /// so the message reflects *where* in each phase someone sits.
    private static func toastText(name: String, x: CGFloat) -> String {
        switch x {
        // ── Mt. Stupid ──
        case ..<0.08:
            return "\(name) just learned what a keyboard is"
        case ..<0.13:
            return "\(name) is scaling Mt. Stupid"
        case ..<0.18:
            return "\(name) is approaching the peak of Mt. Stupid"
        case ..<0.25:
            return "\(name) has mass confidence, zero knowledge"

        // ── Valley of Despair ──
        case ..<0.30:
            return "\(name) is starting to have doubts"
        case ..<0.37:
            return "\(name) is tumbling into the Valley of Despair"
        case ..<0.44:
            return "\(name) has hit rock bottom. It can only get better"
        case ..<0.48:
            return "\(name) is crawling out of the Valley of Despair"

        // ── Slope of Enlightenment ──
        case ..<0.55:
            return "\(name) is finding the Slope of Enlightenment"
        case ..<0.63:
            return "\(name) is grinding up the Slope of Enlightenment"
        case ..<0.72:
            return "\(name) is actually starting to know things"
        case ..<0.78:
            return "\(name) is approaching the Plateau of Sustainability"

        // ── Plateau of Sustainability ──
        case ..<0.85:
            return "\(name) has reached the Plateau of Sustainability"
        case ..<0.92:
            return "\(name) genuinely knows what they're doing"
        default:
            return "\(name) has achieved mass enlightenment"
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
