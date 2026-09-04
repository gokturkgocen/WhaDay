import SwiftUI

struct PlusPaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var purchaseStore: PurchaseStore

    let colors: ThemeColors

    var body: some View {
        ZStack {
            Color(hex: colors.paper).ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header

                    Rectangle()
                        .fill(Color(hex: colors.accent))
                        .frame(width: 38, height: 2)
                        .padding(.top, 36)

                    Text(copy.title)
                        .font(.system(size: 42, weight: .semibold, design: .serif))
                        .tracking(-1.4)
                        .foregroundStyle(Color(hex: colors.ink))
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 18)

                    Text(copy.subtitle)
                        .appFont(size: 16, weight: .regular, relativeTo: .body)
                        .lineSpacing(4)
                        .foregroundStyle(Color(hex: colors.ink).opacity(0.62))
                        .padding(.top, 16)

                    features
                        .padding(.top, 34)

                    purchaseArea
                        .padding(.top, 36)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 36)
            }
            .scrollIndicators(.hidden)
        }
        .alert(
            DayEventStore.language == "tr" ? "Satın alma" : "Purchase",
            isPresented: errorBinding
        ) {
            Button(DayEventStore.language == "tr" ? "Tamam" : "OK", role: .cancel) {
                purchaseStore.errorMessage = nil
            }
        } message: {
            Text(purchaseStore.errorMessage ?? "")
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            BrandMark(color: Color(hex: colors.ink))
                .frame(width: 15, height: 15)
                .scaleEffect(0.34)

            Text("WHADAY+")
                .appFont(size: 12, weight: .semibold, relativeTo: .caption)
                .tracking(2.1)
                .foregroundStyle(Color(hex: colors.ink))

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color(hex: colors.ink))
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(DayEventStore.language == "tr" ? "Kapat" : "Close")
            .accessibilityIdentifier("plus.close")
        }
        .padding(.top, 8)
    }

    private var features: some View {
        VStack(spacing: 0) {
            featureRow("rectangle.3.group", copy.appearances)
            Divider().overlay(Color(hex: colors.ink).opacity(0.10))
            featureRow("sparkles.rectangle.stack", copy.futureTemplates)
        }
    }

    private func featureRow(_ symbol: String, _ title: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: symbol)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(Color(hex: colors.ink))
                .frame(width: 28)

            Text(title)
                .appFont(size: 15, weight: .medium, relativeTo: .body)
                .foregroundStyle(Color(hex: colors.ink))

            Spacer()

            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color(hex: colors.accent))
        }
        .frame(minHeight: 58)
    }

    private var purchaseArea: some View {
        VStack(spacing: 14) {
            Button {
                Task {
                    if await purchaseStore.purchasePlus() {
                        dismiss()
                    }
                }
            } label: {
                HStack {
                    if purchaseStore.isPurchasing {
                        ProgressView().tint(Color(hex: colors.paper))
                    } else if purchaseStore.isPlusUnlocked {
                        Image(systemName: "checkmark")
                        Text(copy.active)
                    } else {
                        Text(copy.buy)
                        Spacer()
                        Text(purchaseStore.displayPrice ?? copy.loadingPrice)
                            .opacity(0.72)
                    }
                }
                .appFont(size: 16, weight: .semibold, relativeTo: .headline)
                .foregroundStyle(Color(hex: colors.paper))
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, minHeight: 58)
                .background(Color(hex: colors.ink))
                .clipShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(purchaseStore.isPurchasing || purchaseStore.isPlusUnlocked)
            .accessibilityIdentifier("plus.purchase")

            Button(copy.restore) {
                Task { await purchaseStore.restorePurchases() }
            }
            .appFont(size: 13, weight: .medium, relativeTo: .callout)
            .foregroundStyle(Color(hex: colors.ink).opacity(0.66))
            .frame(minHeight: 44)
            .buttonStyle(.plain)
            .disabled(purchaseStore.isPurchasing)
            .accessibilityIdentifier("plus.restore")

            Text(copy.finePrint)
                .appFont(size: 11, weight: .regular, relativeTo: .caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color(hex: colors.ink).opacity(0.44))
                .frame(maxWidth: .infinity)
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { purchaseStore.errorMessage != nil },
            set: { if !$0 { purchaseStore.errorMessage = nil } }
        )
    }

    private var copy: Copy {
        Copy(turkish: DayEventStore.language == "tr")
    }
}

private struct Copy {
    let title: String
    let subtitle: String
    let appearances: String
    let futureTemplates: String
    let buy: String
    let active: String
    let restore: String
    let loadingPrice: String
    let finePrint: String

    init(turkish: Bool) {
        if turkish {
            title = "Daha fazla görünüm. Daha az gürültü."
            subtitle = "WhaDay+ paylaşım stüdyosunu iki ek görünümle genişletir. Tek seferlik satın alımdır."
            appearances = "Grafit ve Ton paylaşım görünümleri"
            futureTemplates = "Gelecek premium editoryal şablonlar"
            buy = "WhaDay+’ı aç"
            active = "WhaDay+ etkin"
            restore = "Satın alımları geri yükle"
            loadingPrice = "Hazırlanıyor"
            finePrint = "Tek seferlik satın alma · abonelik yok"
        } else {
            title = "More ways to share. Less noise."
            subtitle = "WhaDay+ expands the sharing studio with two extra appearances. It's a one-time purchase."
            appearances = "Graphite and Tone share appearances"
            futureTemplates = "Future premium editorial templates"
            buy = "Unlock WhaDay+"
            active = "WhaDay+ active"
            restore = "Restore purchases"
            loadingPrice = "Preparing"
            finePrint = "One-time purchase · no subscription"
        }
    }
}
