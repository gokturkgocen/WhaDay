import SwiftUI

struct ActionButtons: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let event: DayEvent
    let prompt: String
    let colors: ThemeColors

    @State private var showingStudio = false

    var body: some View {
        VStack(spacing: 9) {
            Button {
                Haptics.triggerMedium()
                showingStudio = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "paperplane.fill")
                    Text(buttonTitle)
                        .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 1)
                        .minimumScaleFactor(0.76)
                        .fixedSize(horizontal: false, vertical: dynamicTypeSize.isAccessibilitySize)
                    Spacer(minLength: 4)
                    Image(systemName: "sparkles")
                        .font(.system(size: 13, weight: .black))
                }
                .appFont(size: 16, weight: .black, relativeTo: .headline)
                .foregroundStyle(Color(hex: colors.ink))
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(Color(hex: colors.accent))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: Color(hex: colors.accent).opacity(0.22), radius: 18, x: 0, y: 9)
            }
            .accessibilityLabel(DayEventStore.language == "tr" ? "Gönderim Stüdyosunu aç. \(prompt)" : "Open Share Studio. \(prompt)")
            .accessibilityIdentifier("home.share")

            if !dynamicTypeSize.isAccessibilitySize {
                HStack(spacing: 16) {
                    studioCapability("message.fill", DayEventStore.language == "tr" ? "Mesaj" : "Message")
                    studioCapability("rectangle.portrait", "Story")
                    studioCapability("paintpalette.fill", DayEventStore.language == "tr" ? "3 tasarım" : "3 styles")
                }
                .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.56))
                .accessibilityHidden(true)
            }
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .sheet(isPresented: $showingStudio) {
            ShareStudioView(event: event, colors: colors)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
        }
    }

    private func studioCapability(_ symbol: String, _ label: String) -> some View {
        Label(label, systemImage: symbol)
            .appFont(size: 11, weight: .bold, relativeTo: .caption)
    }

    private var buttonTitle: String {
        guard dynamicTypeSize.isAccessibilitySize else { return prompt }
        return DayEventStore.language == "tr" ? "Paylaşım stüdyosunu aç" : "Open Share Studio"
    }
}
