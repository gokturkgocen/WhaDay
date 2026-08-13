import SwiftUI

struct ActionButtons: View {
    let primaryLabel: String
    let secondaryLabel: String
    let shareImage: UIImage?
    let shareTitle: String
    let accentColor: Color

    var body: some View {
        VStack(spacing: 14) {
            shareLink(label: primaryLabel, haptic: Haptics.triggerMedium) {
                Text(primaryLabel)
                    .font(.system(size: 18, weight: .bold, design: .default))
                    .tracking(0.3)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                accentColor.opacity(0.5),
                                accentColor.opacity(0.3)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .strokeBorder(accentColor.opacity(0.7), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: accentColor.opacity(0.3), radius: 12, x: 0, y: 4)
            }

            shareLink(label: secondaryLabel, haptic: Haptics.triggerLight) {
                Text(secondaryLabel)
                    .font(.system(size: 16, weight: .semibold, design: .default))
                    .tracking(0.2)
                    .foregroundStyle(.white.opacity(0.85))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
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
            .transition(.opacity)
        } else {
            content()
                .opacity(0.5)
                .allowsHitTesting(false)
        }
    }
}
