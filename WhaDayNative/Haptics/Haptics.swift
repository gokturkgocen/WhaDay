import UIKit

@MainActor
enum Haptics {
    private static let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private static let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private static let notifyGenerator = UINotificationFeedbackGenerator()

    static func prepare() {
        lightGenerator.prepare()
        mediumGenerator.prepare()
        notifyGenerator.prepare()
    }

    static func triggerLight() {
        lightGenerator.impactOccurred()
    }

    static func triggerMedium() {
        mediumGenerator.impactOccurred()
    }

    static func triggerSuccess() {
        notifyGenerator.notificationOccurred(.success)
    }
}
