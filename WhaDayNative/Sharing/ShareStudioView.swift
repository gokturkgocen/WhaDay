import SwiftUI
import UIKit

struct ShareStudioView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let event: DayEvent
    let colors: ThemeColors

    @State private var format: ShareCardFormat = .message
    @State private var style: ShareCardStyle = .playful
    @State private var selectedPersonalization: SharePersonalization
    @State private var shareImage: UIImage?
    @State private var showingActivity = false
    @State private var renderFailed = false

    private let personalizations: [SharePersonalization]

    init(event: DayEvent, colors: ThemeColors) {
        self.event = event
        self.colors = colors
        let suggestions = SharePersonalization.suggestions(for: event)
        self.personalizations = suggestions
        _selectedPersonalization = State(
            initialValue: suggestions.first(where: { $0.note == nil }) ?? suggestions[0]
        )
    }

    var body: some View {
        ZStack {
            Color(hex: colors.backdrop).ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    header
                    formatControl
                    cardPreview
                    styleSection
                    recipientSection
                    Color.clear.frame(height: 76)
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
                 ? "Lütfen başka bir görünüm seçip yeniden dene."
                 : "Please choose another appearance and try again.")
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 5) {
                Text(DayEventStore.language == "tr" ? "Paylaş" : "Share")
                    .appFont(size: dynamicTypeSize.isAccessibilitySize ? 25 : 32, weight: .semibold, relativeTo: .title)
                    .tracking(-0.9)

                Text(event.title)
                    .appFont(size: 12, weight: .regular, relativeTo: .subheadline)
                    .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.48))
                    .lineLimit(1)
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .medium))
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(DayEventStore.language == "tr" ? "Kapat" : "Close")
            .accessibilityIdentifier("share.close")
        }
        .foregroundStyle(Color(hex: colors.onBackdrop))
    }

    private var formatControl: some View {
        HStack(spacing: 4) {
            ForEach(ShareCardFormat.allCases) { option in
                Button {
                    Haptics.triggerLight()
                    withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.18)) {
                        format = option
                    }
                } label: {
                    Text(option.title)
                        .appFont(size: 13, weight: .semibold, relativeTo: .callout)
                        .foregroundStyle(
                            format == option
                            ? Color(hex: colors.ink)
                            : Color(hex: colors.onBackdrop).opacity(0.58)
                        )
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(format == option ? Color(hex: colors.onBackdrop) : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityValue(format == option ? AccessibilityCopy.selected : "")
                .accessibilityIdentifier("share.format.\(option.rawValue)")
            }
        }
        .padding(3)
        .background(Color(hex: colors.backdropRaised))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
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
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
            )
            .id("\(format.rawValue)-\(style.rawValue)-\(selectedPersonalization.id)")
            .transition(.opacity)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(DayEventStore.language == "tr"
                                ? "Kart önizlemesi, \(style.title), \(format.title)"
                                : "Card preview, \(style.title), \(format.title)")
        }
        .frame(height: format == .story ? 390 : 300)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.18), value: format)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.18), value: style)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.18), value: selectedPersonalization.id)
    }

    private var styleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle(DayEventStore.language == "tr" ? "Görünüm" : "Appearance")

            HStack(spacing: 9) {
                ForEach(ShareCardStyle.allCases) { option in
                    styleChoice(option)
                }
            }
        }
    }

    private var recipientSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle(DayEventStore.language == "tr" ? "Kart notu" : "Card note")

            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(personalizations) { suggestion in
                        Button {
                            Haptics.triggerLight()
                            selectedPersonalization = suggestion
                        } label: {
                            Text(suggestion.label)
                                .appFont(size: 12, weight: .medium, relativeTo: .callout)
                                .foregroundStyle(Color(hex: colors.onBackdrop))
                                .padding(.horizontal, 14)
                                .frame(minHeight: 42)
                                .background(
                                    selectedPersonalization == suggestion
                                    ? Color.white.opacity(0.12)
                                    : Color.clear
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
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

    private func styleChoice(_ option: ShareCardStyle) -> some View {
        let isSelected = style == option
        return Button {
            Haptics.triggerLight()
            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.18)) {
                style = option
            }
        } label: {
            VStack(alignment: .leading, spacing: 9) {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(styleSwatch(option))
                    .frame(height: 30)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                    )

                Text(option.title)
                    .appFont(size: 12, weight: .semibold, relativeTo: .callout)
                    .lineLimit(1)
            }
            .foregroundStyle(Color(hex: colors.onBackdrop))
            .padding(9)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? Color.white.opacity(0.10) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(Color.white.opacity(isSelected ? 0.30 : 0.10), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityValue(isSelected ? AccessibilityCopy.selected : "")
        .accessibilityIdentifier("share.style.\(option.rawValue)")
    }

    private func styleSwatch(_ option: ShareCardStyle) -> Color {
        switch option {
        case .editorial: Color(hex: "#0A0A0A")
        case .playful: Color(hex: colors.paper)
        case .minimal: Color(hex: colors.accent)
        }
    }

    private var shareButton: some View {
        Button {
            Haptics.triggerMedium()
            share()
        } label: {
            HStack(spacing: 10) {
                Text(primaryButtonTitle)
                Spacer()
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
        .buttonStyle(.plain)
        .accessibilityIdentifier("share.primary")
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(Color(hex: colors.backdrop))
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

    private func sectionTitle(_ title: String) -> some View {
        Text(title.uppercased())
            .appFont(size: 10, weight: .semibold, relativeTo: .caption)
            .tracking(1.4)
            .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.46))
    }
}

struct ActivityShareView: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
