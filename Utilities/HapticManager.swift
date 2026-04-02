import UIKit

@MainActor
final class HapticManager: Sendable {
    static let shared = HapticManager()

    private init() {}

    func starProximityTap() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred(intensity: 0.6)
    }

    func starMatchHit() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred(intensity: 1.0)
    }

    func marbleCollision() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred(intensity: 1.0)
    }

}

