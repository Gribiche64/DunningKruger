import SwiftUI

@MainActor
class ChartViewModel: ObservableObject {
    @Published var people: [Person] = []

    private var nextColorIndex: Int = 0
    private let sampler = DKCurveSampler.shared

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
    }

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
