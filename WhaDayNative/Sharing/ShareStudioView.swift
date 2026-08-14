import SwiftUI
import UIKit

struct ShareStudioView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let event: DayEvent
    let colors: ThemeColors

    @State private var format: ShareCardFormat = .message
    @State private var style: ShareCardStyle = .editorial
    @State private var selectedPersonalization: SharePersonalization
    @State private var shareImage: UIImage?
    @State private var showingActivity = false
    @State private var renderFailed = false

    private let personalizations: [SharePersonalization]

    private var usesExpandedChoiceCards: Bool {
        dynamicTypeSize >= .xxLarge
    }

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
                ActivityShareView(items: [shareImage, shareCaption])
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
        .alert(
            DayEventStore.language == "tr" ? "Kart hazırlanamadı" : "Couldn't prepare the card",
            isPresented: $renderFailed
        ) {
            Button(DayEventStore.language == "tr" ? "Tamam" : "OK", role: .cancel) {}
        } message: {
            Text(DayEventStore.language == "tr"
                 ? "Lütfen başka bir tasarım seçip yeniden dene."
                 : "Please choose another style and try again.")
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(DayEventStore.language == "tr" ? "Gönderim Stüdyosu" : "Share Studio")
                    .appFont(size: dynamicTypeSize.isAccessibilitySize ? 22 : 28, weight: .black, relativeTo: .title)
                    .tracking(-0.8)

                Text(DayEventStore.language == "tr"
                     ? "Kartı kişiye ve kanala göre hazırla."
                     : "Make the card fit the person and the channel.")
                    .appFont(size: 13, weight: .semibold, relativeTo: .subheadline)
                    .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.58))
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .black))
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(DayEventStore.language == "tr" ? "Kapat" : "Close")
            .accessibilityIdentifier("share.close")
        }
        .foregroundStyle(Color(hex: colors.onBackdrop))
    }

    private var formatControl: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(spacing: 8) {
                    formatButtons
                }
            } else {
                HStack(spacing: 8) {
                    formatButtons
                }
            }
        }
    }

    @ViewBuilder
    private var formatButtons: some View {
        ForEach(ShareCardFormat.allCases) { option in
            selectionPill(
                title: option.title,
                symbol: option == .story ? "rectangle.portrait" : "message.fill",
                isSelected: format == option
            ) {
                Haptics.triggerLight()
                withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.22)) { format = option }
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
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(DayEventStore.language == "tr"
                                ? "Kart önizlemesi, \(style.title), \(format.title)"
                                : "Card preview, \(style.title), \(format.title)")
        }
        .frame(height: format == .story ? 350 : 300)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.22), value: format)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.22), value: style)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.22), value: selectedPersonalization.id)
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
                                .appFont(size: 13, weight: .black, relativeTo: .callout)
                                .foregroundStyle(
                                    selectedPersonalization == suggestion
                                    ? Color(hex: colors.ink)
                                    : Color(hex: colors.onBackdrop)
                                )
                                .padding(.horizontal, 15)
                                .frame(minHeight: 44)
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
                        .accessibilityValue(selectedPersonalization == suggestion ? AccessibilityCopy.selected : "")
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

            ScrollView(.horizontal) {
                HStack(spacing: 9) {
                    ForEach(ShareCardStyle.allCases) { option in
                        styleChoice(option)
                    }
                }
            }
            .scrollIndicators(.hidden)
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
            .appFont(size: 16, weight: .black, relativeTo: .headline)
            .foregroundStyle(Color(hex: colors.ink))
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, minHeight: 58)
            .background(Color(hex: colors.accent))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: Color.black.opacity(0.26), radius: 20, x: 0, y: 10)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("share.primary")
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background {
            if reduceTransparency {
                Color(hex: colors.backdropRaised)
            } else {
                Rectangle().fill(.ultraThinMaterial)
            }
        }
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
        ) else {
            renderFailed = true
            return
        }

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

    private var shareCaption: String {
        if let note = selectedPersonalization.note {
            return "\(note)\n\(event.title) · WhaDay"
        }
        return "\(event.title) · WhaDay"
    }

    private func sectionTitle(_ title: String, symbol: String) -> some View {
        Label(title, systemImage: symbol)
            .appFont(size: 15, weight: .black, relativeTo: .headline)
            .foregroundStyle(Color(hex: colors.onBackdrop))
    }

    private func selectionPill(
        title: String,
        symbol: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(title, systemImage: isSelected ? "checkmark.circle.fill" : symbol)
                .appFont(size: 12, weight: .black, relativeTo: .callout)
                .foregroundStyle(isSelected ? Color(hex: colors.ink) : Color(hex: colors.onBackdrop))
                .frame(
                    maxWidth: .infinity,
                    minHeight: 44
                )
                .padding(.horizontal, 8)
                .background(isSelected ? Color(hex: colors.accent) : Color.white.opacity(0.07))
                .clipShape(Capsule())
                .overlay(Capsule().strokeBorder(Color.white.opacity(0.12), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityValue(isSelected ? AccessibilityCopy.selected : "")
    }

    private func styleSymbol(_ style: ShareCardStyle) -> String {
        switch style {
        case .editorial: return "text.below.photo"
        case .playful: return "sparkles"
        case .minimal: return "circle.lefthalf.filled"
        }
    }

    private func styleChoice(_ option: ShareCardStyle) -> some View {
        let isSelected = style == option
        return Button {
            Haptics.triggerLight()
            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.20)) { style = option }
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                Image(systemName: styleSymbol(option))
                    .font(.system(size: 15, weight: .black))
                Text(option.title)
                    .appFont(size: 13, weight: .black, relativeTo: .headline)
                Text(option.purpose)
                    .appFont(size: 10, weight: .bold, relativeTo: .caption)
                    .opacity(0.60)
                    .lineLimit(usesExpandedChoiceCards ? 2 : 1)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .foregroundStyle(isSelected ? Color(hex: colors.ink) : Color(hex: colors.onBackdrop))
            .padding(13)
            .frame(width: usesExpandedChoiceCards ? 230 : 132, alignment: .leading)
            .frame(minHeight: 92, alignment: .leading)
            .background(isSelected ? Color(hex: colors.accent) : Color.white.opacity(0.07))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Color.white.opacity(0.12), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityValue(isSelected ? AccessibilityCopy.selected : "")
    }
}

struct ActivityShareView: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
