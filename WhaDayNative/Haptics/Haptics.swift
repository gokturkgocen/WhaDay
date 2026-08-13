import UIKit

@MainActor
enum Haptics {
    private static let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private static let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)

    static func prepare() {
        lightGenerator.prepare()
        mediumGenerator.prepare()
    }

    static func triggerLight() {
        lightGenerator.impactOccurred()
    }

    static func triggerMedium() {
        mediumGenerator.impactOccurred()
    }
}
