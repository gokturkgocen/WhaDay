import UIKit

@MainActor
enum InstagramStorySharer {
    private static let url = URL(string: "instagram-stories://share")!
    private static let backgroundImageType = "com.instagram.sharedSticker.backgroundImage"

    static var isAvailable: Bool {
        UIApplication.shared.canOpenURL(url)
    }

    static func share(image: UIImage) async -> Bool {
        guard isAvailable, let imageData = image.pngData() else { return false }

        UIPasteboard.general.setItems(
            [[backgroundImageType: imageData]],
            options: [
                .expirationDate: Date().addingTimeInterval(5 * 60),
                .localOnly: true
            ]
        )

        return await UIApplication.shared.open(url)
    }
}
