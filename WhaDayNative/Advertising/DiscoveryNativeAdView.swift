import Combine
import GoogleMobileAds
import SwiftUI
import UIKit

struct DiscoveryNativeAdCard: View {
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var advertisingStore: AdvertisingStore
    @StateObject private var model = DiscoveryNativeAdModel()

    let colors: ThemeColors

    var body: some View {
        Group {
            if let nativeAd = model.nativeAd {
                VStack(alignment: .leading, spacing: 10) {
                    EditorialNativeAdRepresentable(nativeAd: nativeAd, colors: colors)
                        .frame(height: 292)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                    Button {
                        guard let url = URL(string: "https://github.com/gokturkgocen/WhaDay/issues/new?title=Uygunsuz%20reklam%20bildirimi") else { return }
                        openURL(url)
                    } label: {
                        Text(DayEventStore.language == "tr" ? "Reklamı bildir" : "Report this ad")
                            .appFont(size: 11, weight: .medium, relativeTo: .caption)
                            .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.48))
                            .frame(minHeight: 44)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("discovery.ad.report")
                }
                .transition(.opacity)
                .accessibilityIdentifier("discovery.ad")
            }
        }
        .task(id: advertisingStore.canLoadDiscoveryAd) {
            guard advertisingStore.canLoadDiscoveryAd,
                  let adUnitID = AdvertisingStore.nativeAdUnitIdentifier else { return }
            model.load(adUnitID: adUnitID)
        }
        .onReceive(model.$nativeAd.compactMap { $0 }.prefix(1)) { _ in
            advertisingStore.markDiscoveryAdDisplayed()
        }
    }
}

@MainActor
private final class DiscoveryNativeAdModel: NSObject, ObservableObject, NativeAdLoaderDelegate {
    @Published private(set) var nativeAd: NativeAd?
    private var adLoader: AdLoader?

    func load(adUnitID: String) {
        guard nativeAd == nil, adLoader == nil else { return }

        let loader = AdLoader(
            adUnitID: adUnitID,
            rootViewController: nil,
            adTypes: [.native],
            options: nil
        )
        loader.delegate = self
        adLoader = loader
        loader.load(Request())
    }

    func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        self.nativeAd = nativeAd
        self.adLoader = nil
    }

    func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
        self.adLoader = nil
    }
}

private struct EditorialNativeAdRepresentable: UIViewRepresentable {
    let nativeAd: NativeAd
    let colors: ThemeColors

    func makeUIView(context: Context) -> EditorialNativeAdUIKitView {
        EditorialNativeAdUIKitView()
    }

    func updateUIView(_ view: EditorialNativeAdUIKitView, context: Context) {
        view.configure(nativeAd: nativeAd, colors: colors)
    }
}

private final class EditorialNativeAdUIKitView: NativeAdView {
    private let sponsorLabel = UILabel()
    private let advertiserLabel = UILabel()
    private let headlineLabel = UILabel()
    private let bodyLabel = UILabel()
    private let callToActionLabel = UILabel()
    private let iconImageView = UIImageView()
    private let mediaAssetView = MediaView()
    private let choicesView = AdChoicesView()
    private let copyStack = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(nativeAd: NativeAd, colors: ThemeColors) {
        let ink = UIColor(Color(hex: colors.ink))
        let paper = UIColor(Color(hex: colors.paper))
        let accent = UIColor(Color(hex: colors.accent))

        backgroundColor = paper
        layer.borderWidth = 1
        layer.borderColor = ink.withAlphaComponent(0.10).cgColor

        sponsorLabel.text = DayEventStore.language == "tr" ? "SPONSORLU" : "SPONSORED"
        sponsorLabel.textColor = ink.withAlphaComponent(0.48)
        advertiserLabel.text = nativeAd.advertiser
        advertiserLabel.textColor = ink.withAlphaComponent(0.55)
        headlineLabel.text = nativeAd.headline
        headlineLabel.textColor = ink
        bodyLabel.text = nativeAd.body
        bodyLabel.textColor = ink.withAlphaComponent(0.62)
        callToActionLabel.text = nativeAd.callToAction
        callToActionLabel.textColor = paper
        callToActionLabel.backgroundColor = ink
        iconImageView.image = nativeAd.icon?.image
        iconImageView.backgroundColor = accent.withAlphaComponent(0.18)
        iconImageView.isHidden = nativeAd.icon == nil
        mediaAssetView.mediaContent = nativeAd.mediaContent
        mediaAssetView.isHidden = !nativeAd.mediaContent.hasVideoContent && nativeAd.images?.isEmpty != false

        self.nativeAd = nativeAd
    }

    private func buildView() {
        clipsToBounds = true

        sponsorLabel.font = .systemFont(ofSize: 9, weight: .semibold)
        sponsorLabel.adjustsFontForContentSizeCategory = true
        advertiserLabel.font = .systemFont(ofSize: 11, weight: .medium)
        advertiserLabel.adjustsFontForContentSizeCategory = true
        advertiserLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        headlineLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        headlineLabel.adjustsFontForContentSizeCategory = true
        headlineLabel.numberOfLines = 2
        bodyLabel.font = .systemFont(ofSize: 12, weight: .regular)
        bodyLabel.adjustsFontForContentSizeCategory = true
        bodyLabel.numberOfLines = 2
        callToActionLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        callToActionLabel.textAlignment = .center
        callToActionLabel.layer.cornerRadius = 9
        callToActionLabel.clipsToBounds = true
        callToActionLabel.isUserInteractionEnabled = false
        iconImageView.contentMode = .scaleAspectFill
        iconImageView.layer.cornerRadius = 10
        iconImageView.clipsToBounds = true
        mediaAssetView.contentMode = .scaleAspectFill
        mediaAssetView.clipsToBounds = true

        let metaStack = UIStackView(arrangedSubviews: [sponsorLabel, advertiserLabel, UIView()])
        metaStack.axis = .horizontal
        metaStack.spacing = 8
        metaStack.alignment = .center

        copyStack.axis = .vertical
        copyStack.spacing = 7
        copyStack.addArrangedSubview(metaStack)
        copyStack.addArrangedSubview(headlineLabel)
        copyStack.addArrangedSubview(bodyLabel)

        let bottomStack = UIStackView(arrangedSubviews: [iconImageView, copyStack, callToActionLabel])
        bottomStack.axis = .horizontal
        bottomStack.spacing = 12
        bottomStack.alignment = .center

        [mediaAssetView, bottomStack, choicesView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        NSLayoutConstraint.activate([
            mediaAssetView.topAnchor.constraint(equalTo: topAnchor),
            mediaAssetView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mediaAssetView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mediaAssetView.heightAnchor.constraint(equalToConstant: 164),

            bottomStack.topAnchor.constraint(equalTo: mediaAssetView.bottomAnchor, constant: 14),
            bottomStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            bottomStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            bottomStack.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -14),

            iconImageView.widthAnchor.constraint(equalToConstant: 46),
            iconImageView.heightAnchor.constraint(equalToConstant: 46),
            callToActionLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 76),
            callToActionLabel.heightAnchor.constraint(equalToConstant: 38),

            choicesView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            choicesView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
        ])

        headlineView = headlineLabel
        bodyView = bodyLabel
        advertiserView = advertiserLabel
        callToActionView = callToActionLabel
        iconView = iconImageView
        mediaView = mediaAssetView
        adChoicesView = choicesView
    }
}
