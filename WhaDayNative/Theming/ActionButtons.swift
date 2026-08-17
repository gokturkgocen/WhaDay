import SwiftUI

struct ActionButtons: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let event: DayEvent
    let prompt: String
    let colors: ThemeColors

    @State private var showingStudio = false

    var body: some View {
        Button {
            Haptics.triggerMedium()
            showingStudio = true
        } label: {
            HStack(spacing: 12) {
                Text(buttonTitle)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 1)
                    .fixedSize(horizontal: false, vertical: dynamicTypeSize.isAccessibilitySize)
                Spacer(minLength: 8)
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 14, weight: .semibold))
            }
            .appFont(size: 16, weight: .semibold, relativeTo: .headline)
            .foregroundStyle(Color(hex: colors.ink))
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(Color(hex: colors.onBackdrop))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .accessibilityLabel(DayEventStore.language == "tr" ? "Paylaş. \(prompt)" : "Share. \(prompt)")
        .accessibilityIdentifier("home.share")
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 14)
        .sheet(isPresented: $showingStudio) {
            ShareStudioView(event: event, colors: colors)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(24)
        }
    }

    private var buttonTitle: String {
        DayEventStore.language == "tr" ? "Paylaş" : "Share"
    }
}
