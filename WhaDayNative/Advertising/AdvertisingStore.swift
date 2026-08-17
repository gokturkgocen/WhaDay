import Combine
import GoogleMobileAds
import SwiftUI
import UserMessagingPlatform

@MainActor
final class AdvertisingStore: ObservableObject {
    @Published private(set) var canRequestAds = false
    @Published private(set) var privacyOptionsRequired = false
    @Published private(set) var isInitialized = false

    private static let lastDiscoveryAdDateKey = "lastDiscoveryAdDate"
    private static let minimumDiscoveryInterval: TimeInterval = 4 * 60 * 60

    private let defaults: UserDefaults
    private var preparedThisSession = false
    private var displayedThisSession = false

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var isConfigured: Bool {
        Self.appIdentifier != nil && Self.nativeAdUnitIdentifier != nil
    }

    var canLoadDiscoveryAd: Bool {
        guard isConfigured, canRequestAds, isInitialized, !displayedThisSession else { return false }
        guard let lastDate = defaults.object(forKey: Self.lastDiscoveryAdDateKey) as? Date else { return true }
        return Date().timeIntervalSince(lastDate) >= Self.minimumDiscoveryInterval
    }

    func prepareIfEligible(isPlusUnlocked: Bool) async {
        guard !isPlusUnlocked, isConfigured, !preparedThisSession else {
            if isPlusUnlocked { deactivate() }
            return
        }
        preparedThisSession = true

        let parameters = RequestParameters()

        await withCheckedContinuation { continuation in
            ConsentInformation.shared.requestConsentInfoUpdate(with: parameters) { _ in
                continuation.resume()
            }
        }

        await withCheckedContinuation { continuation in
            ConsentForm.loadAndPresentIfRequired(from: Self.topViewController) { _ in
                continuation.resume()
            }
        }

        privacyOptionsRequired = ConsentInformation.shared.privacyOptionsRequirementStatus == .required
        guard ConsentInformation.shared.canRequestAds else { return }

        let requestConfiguration = MobileAds.shared.requestConfiguration
        requestConfiguration.publisherPrivacyPersonalizationState = .disabled
        requestConfiguration.setPublisherFirstPartyIDEnabled(false)
        canRequestAds = true
        await withCheckedContinuation { continuation in
            MobileAds.shared.start { _ in continuation.resume() }
        }
        isInitialized = true
    }

    func presentPrivacyOptions() {
        guard privacyOptionsRequired else { return }
        ConsentForm.presentPrivacyOptionsForm(from: Self.topViewController) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.privacyOptionsRequired = ConsentInformation.shared.privacyOptionsRequirementStatus == .required
                self.canRequestAds = ConsentInformation.shared.canRequestAds
            }
        }
    }

    func markDiscoveryAdDisplayed() {
        guard !displayedThisSession else { return }
        displayedThisSession = true
        defaults.set(Date(), forKey: Self.lastDiscoveryAdDateKey)
        objectWillChange.send()
    }

    func deactivate() {
        canRequestAds = false
        isInitialized = false
    }

    static var nativeAdUnitIdentifier: String? {
        configuredString(forInfoKey: "WhaDayNativeAdUnitIdentifier")
    }

    private static var appIdentifier: String? {
        configuredString(forInfoKey: "GADApplicationIdentifier")
    }

    private static func configuredString(forInfoKey key: String) -> String? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private static var topViewController: UIViewController? {
        let root = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .rootViewController
        return topViewController(from: root)
    }

    private static func topViewController(from controller: UIViewController?) -> UIViewController? {
        if let navigation = controller as? UINavigationController {
            return topViewController(from: navigation.visibleViewController)
        }
        if let tab = controller as? UITabBarController {
            return topViewController(from: tab.selectedViewController)
        }
        if let presented = controller?.presentedViewController {
            return topViewController(from: presented)
        }
        return controller
    }
}
