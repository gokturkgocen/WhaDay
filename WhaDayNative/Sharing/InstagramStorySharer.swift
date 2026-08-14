import UIKit

@MainActor
enum InstagramStorySharer {
    private static let backgroundImageType = "com.instagram.sharedSticker.backgroundImage"
    private static let sourceApplicationKey = "WhaDayInstagramSourceApplicationID"

    private static var configuredSourceApplicationID: String? {
        Bundle.main.object(forInfoDictionaryKey: sourceApplicationKey) as? String
    }

    static var isAvailable: Bool {
        guard let url = shareURL(sourceApplicationID: configuredSourceApplicationID) else {
            return false
        }
        return UIApplication.shared.canOpenURL(url)
    }

    static func share(image: UIImage) async -> Bool {
        guard
            let url = shareURL(sourceApplicationID: configuredSourceApplicationID),
            UIApplication.shared.canOpenURL(url),
            let imageData = image.pngData()
        else {
            return false
        }

        UIPasteboard.general.setItems(
            [[backgroundImageType: imageData]],
            options: [
                .expirationDate: Date().addingTimeInterval(5 * 60),
                .localOnly: true
            ]
        )

        return await UIApplication.shared.open(url)
    }

    static func shareURL(sourceApplicationID: String?) -> URL? {
        guard let sourceApplicationID else { return nil }
        let normalized = sourceApplicationID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty, !normalized.contains("$(") else { return nil }

        var components = URLComponents(string: "instagram-stories://share")
        components?.queryItems = [
            URLQueryItem(name: "source_application", value: normalized)
        ]
        return components?.url
    }
}
