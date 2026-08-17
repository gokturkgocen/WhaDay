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
        case (.editorial, "tr"): return "Grafit"
        case (.playful, "tr"): return "Fildişi"
        case (.minimal, "tr"): return "Ton"
        case (.editorial, _): return "Graphite"
        case (.playful, _): return "Ivory"
        case (.minimal, _): return "Tone"
        }
    }

    var purpose: String {
        let tr = DayEventStore.language == "tr"
        switch self {
        case .editorial: return tr ? "Koyu" : "Dark"
        case .playful: return tr ? "Açık" : "Light"
        case .minimal: return tr ? "Günün tonu" : "Daily tone"
        }
    }
}

enum ShareCardLayout {
    static func titleSize(characterCount: Int, format: ShareCardFormat) -> CGFloat {
        switch (format, characterCount) {
        case (.message, 111...): return 21
        case (.message, 81...): return 24
        case (.message, 56...): return 28
        case (.message, 36...): return 32
        case (.message, _): return 39
        case (.story, 111...): return 25
        case (.story, 81...): return 29
        case (.story, 56...): return 34
        case (.story, 36...): return 41
        case (.story, _): return 50
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
        style: ShareCardStyle = .playful,
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

    private var backgroundColor: Color {
        switch style {
        case .editorial: Color(hex: "#0A0A0A")
        case .playful: Color(hex: colors.paper)
        case .minimal: Color(hex: colors.accent)
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .editorial: Color(hex: colors.paper)
        case .playful, .minimal: Color(hex: colors.ink)
        }
    }

    private var secondaryColor: Color {
        foregroundColor.opacity(style == .editorial ? 0.58 : 0.62)
    }

    private var signalColor: Color {
        switch style {
        case .editorial: Color(hex: colors.accent)
        case .playful, .minimal: Color(hex: colors.ink)
        }
    }

    private var dateText: String {
        guard let event else { return "" }
        var components = DateComponents()
        components.month = event.month
        components.day = event.day
        components.year = 2024
        guard let date = Calendar(identifier: .gregorian).date(from: components) else { return "" }

        let formatter = DateFormatter()
        formatter.locale = language == "tr" ? Locale(identifier: "tr_TR") : Locale(identifier: "en_US")
        formatter.setLocalizedDateFormatFromTemplate("d MMMM")
        return formatter.string(from: date)
    }

    private var dayIndex: String {
        guard let event else { return "000 / 366" }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        guard let date = calendar.date(from: DateComponents(year: 2024, month: event.month, day: event.day)),
              let ordinal = calendar.ordinality(of: .day, in: .year, for: date) else {
            return "000 / 366"
        }
        return String(format: "%03d / 366", ordinal)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            cardHeader

            Spacer(minLength: format == .story ? 44 : 24)

            Rectangle()
                .fill(signalColor)
                .frame(width: 34, height: 2)

            Text(event?.title ?? Strings.noEventTitle)
                .font(.system(size: titleSize, weight: .semibold, design: .serif))
                .tracking(-1.25)
                .foregroundStyle(foregroundColor)
                .lineLimit(format == .story ? 5 : 4)
                .minimumScaleFactor(0.70)
                .allowsTightening(true)
                .padding(.top, format == .story ? 18 : 14)
                .layoutPriority(2)

            Text(editorial?.fact ?? Strings.noEventDesc)
                .font(.system(size: format == .story ? 14.5 : 13, weight: .regular))
                .lineSpacing(format == .story ? 4 : 3)
                .foregroundStyle(secondaryColor)
                .lineLimit(format == .story ? 4 : 3)
                .minimumScaleFactor(0.78)
                .padding(.top, format == .story ? 22 : 17)
                .layoutPriority(1)

            if let personalNote, !personalNote.isEmpty {
                Text(personalNote)
                    .font(.system(size: format == .story ? 12.5 : 11.5, weight: .medium))
                    .foregroundStyle(foregroundColor.opacity(0.86))
                    .lineLimit(2)
                    .padding(.top, 18)
            }

            Spacer(minLength: 18)
            cardFooter
        }
        .padding(.horizontal, format == .story ? 30 : 26)
        .padding(.vertical, ShareCardLayout.verticalSafeInset(format: format))
        .frame(width: format.canvasSize.width, height: format.canvasSize.height, alignment: .topLeading)
        .background(backgroundColor)
        .clipped()
    }

    private var cardHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(dateText.uppercased())
                .font(.system(size: 10, weight: .semibold))
                .tracking(1.35)

            Spacer()

            Text(dayIndex)
                .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                .tracking(0.45)
        }
        .foregroundStyle(secondaryColor)
    }

    private var cardFooter: some View {
        HStack(spacing: 7) {
            BrandMark(color: foregroundColor)
                .frame(width: 13, height: 13)
                .scaleEffect(0.28)

            Text("WHADAY")
                .font(.system(size: 9.5, weight: .semibold))
                .tracking(1.55)
        }
        .foregroundStyle(foregroundColor.opacity(0.80))
    }

    private var titleSize: CGFloat {
        ShareCardLayout.titleSize(characterCount: event?.title.count ?? 0, format: format)
    }
}
