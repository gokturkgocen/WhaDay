import SwiftUI
import UIKit

struct ShareStudioView: View {
    @Environment(\.dismiss) private var dismiss

    let event: DayEvent
    let colors: ThemeColors

    @State private var format: ShareCardFormat = .message
    @State private var style: ShareCardStyle = .editorial
    @State private var selectedPersonalization: SharePersonalization
    @State private var shareImage: UIImage?
    @State private var showingActivity = false

    private let personalizations: [SharePersonalization]

    init(event: DayEvent, colors: ThemeColors) {
        self.event = event
        self.colors = colors
        let suggestions = SharePersonalization.suggestions(for: event)
        self.personalizations = suggestions
        _selectedPersonalization = State(initialValue: suggestions[0])
    }

    var body: some View {
        ZStack {
            Color(hex: colors.backdrop).ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    formatControl
                    cardPreview
                    recipientSection
                    styleSection
                    Color.clear.frame(height: 82)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .scrollIndicators(.hidden)
        }
        .safeAreaInset(edge: .bottom) {
            shareButton
        }
        .sheet(isPresented: $showingActivity) {
            if let shareImage {
                ActivityShareView(items: [shareImage])
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(DayEventStore.language == "tr" ? "Gönderim Stüdyosu" : "Share Studio")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .tracking(-0.8)

                Text(DayEventStore.language == "tr"
                     ? "Kartı kişiye ve kanala göre hazırla."
                     : "Make the card fit the person and the channel.")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.58))
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .black))
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .foregroundStyle(Color(hex: colors.onBackdrop))
    }

    private var formatControl: some View {
        HStack(spacing: 8) {
            ForEach(ShareCardFormat.allCases) { option in
                selectionPill(
                    title: option.title,
                    symbol: option == .story ? "rectangle.portrait" : "message.fill",
                    isSelected: format == option
                ) {
                    Haptics.triggerLight()
                    withAnimation(.easeInOut(duration: 0.22)) { format = option }
                }
            }
        }
    }

    private var cardPreview: some View {
        GeometryReader { proxy in
            let canvas = format.canvasSize
            let scale = min(proxy.size.width / canvas.width, proxy.size.height / canvas.height)

            ShareCardView(
                event: event,
                colors: colors,
                format: format,
                style: style,
                personalNote: selectedPersonalization.note
            )
            .scaleEffect(scale, anchor: .topLeading)
            .frame(width: canvas.width * scale, height: canvas.height * scale, alignment: .topLeading)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .id("\(format.rawValue)-\(style.rawValue)-\(selectedPersonalization.id)")
            .transition(.opacity.combined(with: .scale(scale: 0.98)))
        }
        .frame(height: format == .story ? 350 : 300)
        .animation(.easeInOut(duration: 0.22), value: format)
        .animation(.easeInOut(duration: 0.22), value: style)
        .animation(.easeInOut(duration: 0.22), value: selectedPersonalization.id)
    }

    private var recipientSection: some View {
        VStack(alignment: .leading, spacing: 11) {
            sectionTitle(
                DayEventStore.language == "tr" ? "Sana kimi hatırlattı?" : "Who came to mind?",
                symbol: "person.2.fill"
            )

            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(personalizations) { suggestion in
                        Button {
                            Haptics.triggerLight()
                            selectedPersonalization = suggestion
                        } label: {
                            Text(suggestion.label)
                                .font(.system(size: 13, weight: .black, design: .rounded))
                                .foregroundStyle(
                                    selectedPersonalization == suggestion
                                    ? Color(hex: colors.ink)
                                    : Color(hex: colors.onBackdrop)
                                )
                                .padding(.horizontal, 15)
                                .frame(height: 40)
                                .background(
                                    selectedPersonalization == suggestion
                                    ? Color(hex: colors.accent)
                                    : Color.white.opacity(0.07)
                                )
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule().strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }

    private var styleSection: some View {
        VStack(alignment: .leading, spacing: 11) {
            sectionTitle(
                DayEventStore.language == "tr" ? "Kartın havası" : "Card style",
                symbol: "paintpalette.fill"
            )

            HStack(spacing: 8) {
                ForEach(ShareCardStyle.allCases) { option in
                    selectionPill(
                        title: option.title,
                        symbol: styleSymbol(option),
                        isSelected: style == option
                    ) {
                        Haptics.triggerLight()
                        style = option
                    }
                }
            }
        }
    }

    private var shareButton: some View {
        Button {
            Haptics.triggerMedium()
            share()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: format == .story ? "rectangle.portrait.on.rectangle.portrait" : "paperplane.fill")
                Text(primaryButtonTitle)
                Spacer()
                Image(systemName: "arrow.up.right")
            }
            .font(.system(size: 16, weight: .black, design: .rounded))
            .foregroundStyle(Color(hex: colors.ink))
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, minHeight: 58)
            .background(Color(hex: colors.accent))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: Color.black.opacity(0.26), radius: 20, x: 0, y: 10)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(.ultraThinMaterial)
    }

    private var primaryButtonTitle: String {
        if format == .story && InstagramStorySharer.isAvailable {
            return DayEventStore.language == "tr" ? "Instagram Story’ye gönder" : "Send to Instagram Stories"
        }
        return DayEventStore.language == "tr" ? "Paylaş" : "Share"
    }

    private func share() {
        guard let image = ShareCardRenderer.render(
            event: event,
            colors: colors,
            format: format,
            style: style,
            personalNote: selectedPersonalization.note
        ) else { return }

        shareImage = image

        guard format == .story else {
            showingActivity = true
            return
        }

        Task { @MainActor in
            if await InstagramStorySharer.share(image: image) {
                dismiss()
            } else {
                showingActivity = true
            }
        }
    }

    private func sectionTitle(_ title: String, symbol: String) -> some View {
        Label(title, systemImage: symbol)
            .font(.system(size: 15, weight: .black, design: .rounded))
            .foregroundStyle(Color(hex: colors.onBackdrop))
    }

    private func selectionPill(
        title: String,
        symbol: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(title, systemImage: symbol)
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(isSelected ? Color(hex: colors.ink) : Color(hex: colors.onBackdrop))
                .frame(maxWidth: .infinity, minHeight: 42)
                .padding(.horizontal, 8)
                .background(isSelected ? Color(hex: colors.accent) : Color.white.opacity(0.07))
                .clipShape(Capsule())
                .overlay(Capsule().strokeBorder(Color.white.opacity(0.12), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func styleSymbol(_ style: ShareCardStyle) -> String {
        switch style {
        case .editorial: return "text.below.photo"
        case .midnight: return "moon.stars.fill"
        case .poster: return "rectangle.fill.on.rectangle.fill"
        }
    }
}

struct ActivityShareView: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
