import SwiftUI

struct ActionButtons: View {
    let primaryLabel: String
    let secondaryLabel: String
    let shareImage: UIImage?
    let shareTitle: String
    let accentColor: Color

    var body: some View {
        VStack(spacing: 12) {
            shareLink(label: primaryLabel, haptic: Haptics.triggerMedium) {
                Text(primaryLabel)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(accentColor.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(accentColor.opacity(0.6), lineWidth: 0.5)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }

            shareLink(label: secondaryLabel, haptic: Haptics.triggerLight) {
                Text(secondaryLabel)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(.vertical, 14)
                    .padding(.horizontal, 28)
                    .background(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color.white.opacity(0.12), lineWidth: 0.5)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(.horizontal, 28)
        .padding(.bottom, 48)
    }

    @ViewBuilder
    private func shareLink<Label: View>(label: String, haptic: @escaping () -> Void, @ViewBuilder content: () -> Label) -> some View {
        if let shareImage {
            ShareLink(
                item: Image(uiImage: shareImage),
                preview: SharePreview(shareTitle, image: Image(uiImage: shareImage))
            ) {
                content()
            }
            .simultaneousGesture(TapGesture().onEnded { haptic() })
        } else {
            content().opacity(0.5)
        }
    }
}
