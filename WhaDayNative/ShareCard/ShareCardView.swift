import SwiftUI

enum ShareCardFormat: String, CaseIterable, Identifiable {
    case story
    case message

    var id: String { rawValue }

    var title: String {
        switch (self, DayEventStore.language) {
        case (.story, "tr"): return "Story"
        case (.message, "tr"): return "Mesaj"
        case (.story, _): return "Story"
        case (.message, _): return "Message"
        }
    }

    var canvasSize: CGSize {
        switch self {
        case .story: return CGSize(width: 360, height: 640)
        case .message: return CGSize(width: 360, height: 450)
        }
    }
}

enum ShareCardStyle: String, CaseIterable, Identifiable {
    case editorial
    case playful
    case minimal

    var id: String { rawValue }

    var title: String {
        switch (self, DayEventStore.language) {
        case (.editorial, "tr"): return "Editoryal"
        case (.playful, "tr"): return "Oyunbaz"
        case (.minimal, "tr"): return "Minimal"
        case (.editorial, _): return "Editorial"
        case (.playful, _): return "Playful"
        case (.minimal, _): return "Minimal"
        }
    }

    var purpose: String {
        let tr = DayEventStore.language == "tr"
        switch self {
        case .editorial: return tr ? "Bilgi + bağlam" : "Fact + context"
        case .playful: return tr ? "Büyük ve enerjik" : "Bold + energetic"
        case .minimal: return tr ? "Sakin ve net" : "Calm + clear"
        }
    }
}

enum ShareCardLayout {
    static func titleSize(characterCount: Int, format: ShareCardFormat) -> CGFloat {
        switch (format, characterCount) {
        case (.message, 111...): return 21
        case (.message, 81...): return 24
        case (.message, 56...): return 27
        case (.message, 36...): return 31
        case (.message, _): return 37
        case (.story, 111...): return 24
        case (.story, 81...): return 28
        case (.story, 56...): return 33
        case (.story, 36...): return 39
        case (.story, _): return 47
        }
    }

    static func verticalSafeInset(format: ShareCardFormat) -> CGFloat {
        format == .story ? 84 : 24
    }
}

struct ShareCardView: View {
    let event: DayEvent?
    let colors: ThemeColors
    let format: ShareCardFormat
    let style: ShareCardStyle
    let personalNote: String?
    let language: String

    init(
        event: DayEvent?,
        colors: ThemeColors,
        format: ShareCardFormat,
        style: ShareCardStyle = .editorial,
        personalNote: String? = nil,
        language: String = DayEventStore.language
    ) {
        self.event = event
        self.colors = colors
        self.format = format
        self.style = style
        self.personalNote = personalNote
        self.language = language
    }

    private var editorial: EditorialContent? {
        event.map { EditorialContent.forEvent($0, language: language) }
    }

    private var dateText: String {
        var components = DateComponents()
        components.month = event?.month ?? 1
        components.day = event?.day ?? 1
        components.year = Calendar.current.component(.year, from: Date())
        guard let date = Calendar.current.date(from: components) else { return "" }
        let formatter = DateFormatter()
        formatter.locale = language == "tr" ? Locale(identifier: "tr_TR") : Locale(identifier: "en_US")
        formatter.setLocalizedDateFormatFromTemplate("d MMMM")
        return formatter.string(from: date)
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: colors.backdrop), Color(hex: colors.backdropRaised)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            glowField
            decorativeLayer

            VStack(alignment: .leading, spacing: 0) {
                cardHeader
                Spacer(minLength: format == .story ? 12 : 14)
                selectedCard
                Spacer(minLength: format == .story ? 12 : 12)
                cardFooter
            }
            .padding(.horizontal, format == .story ? 28 : 24)
            .padding(.vertical, ShareCardLayout.verticalSafeInset(format: format))
        }
        .frame(width: format.canvasSize.width, height: format.canvasSize.height)
        .clipped()
    }

    @ViewBuilder
    private var selectedCard: some View {
        switch style {
        case .editorial:
            vividCard
        case .playful:
            posterCard
        case .minimal:
            midnightCard
        }
    }

    private var cardHeader: some View {
        HStack(spacing: 8) {
            BrandMark(color: Color(hex: colors.secondary))
                .frame(width: 21, height: 21)
                .scaleEffect(0.50)
            Text("WHADAY")
                .font(.system(size: 11, weight: .black, design: .rounded))
                .tracking(1)

            Spacer()

            Text(dateText.uppercased())
                .font(.system(size: 10, weight: .black, design: .rounded))
                .tracking(1)
                .opacity(0.62)
        }
        .foregroundStyle(Color(hex: colors.onBackdrop))
        .opacity(0.82)
    }

    private var vividCard: some View {
        VStack(alignment: .leading, spacing: format == .story ? 14 : 11) {
            HStack(alignment: .center) {
                Text(editorial?.eyebrow ?? "WHADAY")
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .tracking(1.3)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(Color(hex: colors.ink).opacity(0.88))
                    .foregroundStyle(Color(hex: colors.onBackdrop))
                    .clipShape(Capsule())

                Spacer()

                Text(event.map(EditorialSymbol.forEvent) ?? "✦")
                    .font(.system(size: format == .story ? 38 : 32))
                    .rotationEffect(.degrees(5))
            }

            Text(event?.title ?? Strings.noEventTitle)
                .font(.system(size: titleSize, weight: .black, design: .rounded))
                .tracking(-1.6)
                .foregroundStyle(Color(hex: colors.ink))
                .lineLimit(format == .story ? 5 : 4)
                .minimumScaleFactor(0.72)
                .allowsTightening(true)

            Rectangle()
                .fill(Color(hex: colors.ink).opacity(0.7))
                .frame(height: 1.5)

            Text(editorial?.fact ?? Strings.noEventDesc)
                .font(.system(size: format == .story ? 14 : 12.5, weight: .semibold, design: .rounded))
                .lineSpacing(format == .story ? 3 : 2)
                .foregroundStyle(Color(hex: colors.ink).opacity(0.78))
                .lineLimit(3)
                .minimumScaleFactor(0.72)
        }
        .padding(format == .story ? 20 : 18)
        .background(
            LinearGradient(
                colors: [Color(hex: colors.paper), Color(hex: colors.blob1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
        )
        .shadow(color: Color(hex: colors.accent).opacity(0.30), radius: 28, x: 0, y: 16)
    }

    private var midnightCard: some View {
        VStack(alignment: .leading, spacing: format == .story ? 14 : 11) {
            HStack {
                Text(editorial?.eyebrow ?? "WHADAY")
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .tracking(1.4)
                    .foregroundStyle(Color(hex: colors.secondary))

                Spacer()

                Text(event.map(EditorialSymbol.forEvent) ?? "✦")
                    .font(.system(size: format == .story ? 34 : 30))
            }

            Text(event?.title ?? Strings.noEventTitle)
                .font(.system(size: titleSize - 2, weight: .black, design: .rounded))
                .tracking(-1.5)
                .foregroundStyle(Color(hex: colors.onBackdrop))
                .lineLimit(format == .story ? 5 : 4)
                .minimumScaleFactor(0.72)
                .allowsTightening(true)

            Capsule()
                .fill(Color(hex: colors.accent))
                .frame(width: 48, height: 4)

            Text(editorial?.fact ?? Strings.noEventDesc)
                .font(.system(size: format == .story ? 14 : 12.5, weight: .semibold, design: .rounded))
                .lineSpacing(3)
                .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.68))
                .lineLimit(3)
                .minimumScaleFactor(0.72)
        }
        .padding(format == .story ? 21 : 18)
        .background(Color(hex: colors.backdropRaised).opacity(0.96))
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .strokeBorder(Color(hex: colors.accent).opacity(0.34), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.34), radius: 24, x: 0, y: 14)
    }

    private var posterCard: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(
                colors: [Color(hex: colors.paper), Color(hex: colors.secondary)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Text(event.map(EditorialSymbol.forEvent) ?? "✦")
                .font(.system(size: format == .story ? 132 : 104))
                .opacity(0.16)
                .rotationEffect(.degrees(11))
                .offset(x: format == .story ? 142 : 168, y: -30)

            VStack(alignment: .leading, spacing: format == .story ? 14 : 11) {
                Text(dateText.uppercased())
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                    .tracking(1.4)

                Spacer(minLength: format == .story ? 24 : 14)

                Text(event?.title ?? Strings.noEventTitle)
                    .font(.system(size: titleSize + 1, weight: .black, design: .rounded))
                    .tracking(-1.8)
                    .lineLimit(format == .story ? 5 : 4)
                    .minimumScaleFactor(0.70)
                    .allowsTightening(true)

                Rectangle()
                    .fill(Color(hex: colors.ink))
                    .frame(height: 2)

                Text(editorial?.fact ?? Strings.noEventDesc)
                    .font(.system(size: format == .story ? 14 : 12.5, weight: .bold, design: .rounded))
                    .lineSpacing(3)
                    .lineLimit(3)
                    .minimumScaleFactor(0.7)
                    .opacity(0.75)
            }
            .foregroundStyle(Color(hex: colors.ink))
            .padding(format == .story ? 21 : 18)
        }
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
        )
        .shadow(color: Color(hex: colors.accent).opacity(0.28), radius: 26, x: 0, y: 16)
    }

    private var cardFooter: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(personalNote ?? editorial?.prompt ?? Strings.shareOnStory)
                .font(.system(size: format == .story ? 16 : 13, weight: .black, design: .rounded))
                .foregroundStyle(Color(hex: colors.onBackdrop))
                .lineLimit(2)

            HStack(spacing: 7) {
                Capsule()
                    .fill(Color(hex: colors.secondary))
                    .frame(width: 22, height: 4)
                Text(footerLabel)
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .tracking(0.8)
                    .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.52))
            }
        }
    }

    private var footerLabel: String {
        let isRemembrance = editorial?.tone == .remembrance
        if language == "tr" {
            return isRemembrance ? "GÜNÜN NOTU" : "GÜNÜN BAHANESİ"
        }
        return isRemembrance ? "TODAY'S NOTE" : "TODAY'S EXCUSE"
    }

    private var glowField: some View {
        ZStack {
            Circle()
                .fill(Color(hex: colors.accent).opacity(0.30))
                .frame(width: format == .story ? 310 : 240)
                .blur(radius: 55)
                .offset(x: 145, y: format == .story ? -260 : -180)
            Circle()
                .fill(Color(hex: colors.secondary).opacity(0.16))
                .frame(width: 230)
                .blur(radius: 65)
                .offset(x: -155, y: format == .story ? 270 : 195)
        }
    }

    private var fineGrid: some View {
        Canvas { context, size in
            let spacing: CGFloat = 24
            for x in stride(from: 0, through: size.width, by: spacing) {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(path, with: .color(.white.opacity(0.035)), lineWidth: 0.5)
            }
            for y in stride(from: 0, through: size.height, by: spacing) {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(path, with: .color(.white.opacity(0.035)), lineWidth: 0.5)
            }
        }
    }

    @ViewBuilder
    private var decorativeLayer: some View {
        switch style {
        case .editorial:
            fineGrid
        case .playful:
            ZStack {
                RoundedRectangle(cornerRadius: 34)
                    .stroke(Color(hex: colors.secondary).opacity(0.14), lineWidth: 18)
                    .frame(width: 250, height: 250)
                    .rotationEffect(.degrees(18))
                    .offset(x: 145, y: -210)
                Circle()
                    .stroke(Color(hex: colors.accent).opacity(0.12), lineWidth: 14)
                    .frame(width: 180)
                    .offset(x: -155, y: format == .story ? 250 : 170)
            }
        case .minimal:
            EmptyView()
        }
    }

    private var titleSize: CGFloat {
        ShareCardLayout.titleSize(characterCount: event?.title.count ?? 0, format: format)
    }
}
