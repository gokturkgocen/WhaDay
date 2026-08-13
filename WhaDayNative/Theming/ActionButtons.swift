import SwiftUI

struct ActionButtons: View {
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
                    Text(prompt)
                        .lineLimit(1)
                        .minimumScaleFactor(0.76)
                    Spacer(minLength: 4)
                    Image(systemName: "sparkles")
                        .font(.system(size: 13, weight: .black))
                }
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundStyle(Color(hex: colors.ink))
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(Color(hex: colors.accent))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: Color(hex: colors.accent).opacity(0.22), radius: 18, x: 0, y: 9)
            }

            HStack(spacing: 16) {
                studioCapability("message.fill", DayEventStore.language == "tr" ? "Mesaj" : "Message")
                studioCapability("rectangle.portrait", "Story")
                studioCapability("paintpalette.fill", DayEventStore.language == "tr" ? "3 tasarım" : "3 styles")
            }
            .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.56))
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
            .font(.system(size: 11, weight: .bold, design: .rounded))
    }
}
