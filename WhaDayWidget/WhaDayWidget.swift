import SwiftUI
import WidgetKit

struct WidgetPalette {
    let paper: Color
    let ink: Color
    let accent: Color

    static func forTheme(_ theme: String) -> WidgetPalette {
        let accent: String
        switch theme {
        case "nature": accent = "#829B77"
        case "science": accent = "#8297BA"
        case "peace": accent = "#879EAE"
        case "culture": accent = "#B79B69"
        case "lifestyle": accent = "#B18A72"
        case "health": accent = "#78A49B"
        case "social": accent = "#A18DAA"
        case "community": accent = "#9A8AA7"
        case "diversity": accent = "#A78C9F"
        case "sport": accent = "#7898A8"
        case "fun": accent = "#7FA3B5"
        default: accent = "#929292"
        }

        return WidgetPalette(
            paper: Color(hex: "#F2F0E8") ?? .white,
            ink: Color(hex: "#11110F") ?? .black,
            accent: Color(hex: accent) ?? .gray
        )
    }
}

struct WhaDayEntry: TimelineEntry {
    let date: Date
    let dayID: String?
    let symbol: String
    let title: String
    let palette: WidgetPalette
    let language: String
    let sensitivity: WidgetDaySensitivity

    private var locale: Locale {
        Locale(identifier: language == "tr" ? "tr_TR" : "en_US")
    }

    var dayNumber: String {
        String(Calendar.autoupdatingCurrent.component(.day, from: date))
    }

    var month: String {
        date
            .formatted(.dateTime.month(.abbreviated).locale(locale))
            .uppercased(with: locale)
    }

    var weekday: String {
        date
            .formatted(.dateTime.weekday(.wide).locale(locale))
            .uppercased(with: locale)
    }

    var eyebrow: String {
        if sensitivity == .standard {
            return language == "tr" ? "BUGÜN" : "TODAY"
        }
        return language == "tr" ? "BUGÜNÜN NOTU" : "TODAY'S NOTE"
    }

    var accessibilitySummary: String {
        "\(dayNumber) \(month). \(title)"
    }
}

struct WhaDayProvider: TimelineProvider {
    func placeholder(in context: Context) -> WhaDayEntry {
        WhaDayEntry(
            date: Date(),
            dayID: "08-13",
            symbol: "✦",
            title: "Dünya Solaklar Günü",
            palette: .forTheme("fun"),
            language: "tr",
            sensitivity: .standard
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (WhaDayEntry) -> Void) {
        completion(context.isPreview ? placeholder(in: context) : loadEntry(at: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WhaDayEntry>) -> Void) {
        let now = Date()
        let calendar = Calendar.autoupdatingCurrent
        completion(Timeline(
            entries: [loadEntry(at: now, calendar: calendar)],
            policy: .after(WidgetDayCatalog.nextLocalMidnight(after: now, calendar: calendar))
        ))
    }

    private func loadEntry(
        at date: Date,
        calendar: Calendar = .autoupdatingCurrent
    ) -> WhaDayEntry {
        let language = WidgetDayCatalog.languageCode(preferredLanguages: Locale.preferredLanguages)
        guard
            let localizedURL = Bundle.main.url(forResource: language, withExtension: "json"),
            let localizedData = try? Data(contentsOf: localizedURL),
            let events = try? WidgetDayCatalog.decode(
                localizedData: localizedData,
                metadataData: Bundle.main.url(forResource: "metadata", withExtension: "json")
                    .flatMap { try? Data(contentsOf: $0) }
            ),
            let event = WidgetDayCatalog.event(at: date, calendar: calendar, events: events)
        else {
            return fallbackEntry(at: date, language: language)
        }

        return WhaDayEntry(
            date: date,
            dayID: event.id,
            symbol: event.symbol,
            title: event.title,
            palette: .forTheme(event.themeKey),
            language: language,
            sensitivity: event.sensitivity
        )
    }

    private func fallbackEntry(at date: Date, language: String) -> WhaDayEntry {
        WhaDayEntry(
            date: date,
            dayID: nil,
            symbol: "✦",
            title: language == "tr" ? "Bugünün günü hazırlanıyor" : "Today's day is getting ready",
            palette: .forTheme("default"),
            language: language,
            sensitivity: .considerate
        )
    }
}

struct WhaDayWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: WhaDayEntry

    var body: some View {
        content
            .widgetURL(entry.dayID.flatMap { URL(string: "whaday://day/\($0)") })
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(entry.accessibilitySummary)
            .accessibilityHint(entry.language == "tr" ? "Günü WhaDay'de açar" : "Opens the day in WhaDay")
    }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .systemMedium:
            mediumView
                .containerBackground(entry.palette.paper, for: .widget)
        case .accessoryRectangular:
            rectangularAccessoryView
                .containerBackground(.clear, for: .widget)
        case .accessoryInline:
            inlineAccessoryView
                .containerBackground(.clear, for: .widget)
        case .accessoryCircular:
            circularAccessoryView
                .containerBackground(.clear, for: .widget)
        default:
            smallView
                .containerBackground(entry.palette.paper, for: .widget)
        }
    }

    private var smallView: some View {
        VStack(alignment: .leading, spacing: 0) {
            dateHeader

            Spacer(minLength: 12)

            accentRule(width: 28)

            Text(entry.title)
                .font(.system(size: 20, weight: .semibold, design: .serif))
                .tracking(-0.65)
                .foregroundStyle(entry.palette.ink)
                .lineLimit(4)
                .minimumScaleFactor(0.72)
                .padding(.top, 10)

            Spacer(minLength: 8)

            wordmark
        }
    }

    private var mediumView: some View {
        HStack(spacing: 17) {
            VStack(alignment: .leading, spacing: 0) {
                Text(entry.month)
                    .font(.system(size: 10, weight: .semibold, design: .default))
                    .tracking(1.5)
                    .foregroundStyle(entry.palette.ink.opacity(0.5))

                Text(entry.dayNumber)
                    .font(.system(size: 46, weight: .medium, design: .serif))
                    .tracking(-1.5)
                    .foregroundStyle(entry.palette.ink)
                    .padding(.top, -2)

                Spacer(minLength: 10)

                wordmark
            }
            .frame(width: 75, alignment: .leading)

            Rectangle()
                .fill(entry.palette.ink.opacity(0.12))
                .frame(width: 1)

            VStack(alignment: .leading, spacing: 0) {
                Text(entry.eyebrow)
                    .font(.system(size: 9, weight: .semibold))
                    .tracking(1.45)
                    .foregroundStyle(entry.palette.ink.opacity(0.48))

                Spacer(minLength: 12)

                accentRule(width: 34)

                Text(entry.title)
                    .font(.system(size: 23, weight: .semibold, design: .serif))
                    .tracking(-0.75)
                    .foregroundStyle(entry.palette.ink)
                    .lineLimit(3)
                    .minimumScaleFactor(0.72)
                    .padding(.top, 10)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var rectangularAccessoryView: some View {
        HStack(spacing: 10) {
            Rectangle()
                .fill(.primary)
                .frame(width: 2)
                .widgetAccentable()

            VStack(alignment: .leading, spacing: 2) {
                Text("\(entry.dayNumber) \(entry.month) · \(entry.eyebrow)")
                    .font(.system(size: 9, weight: .semibold))
                    .tracking(0.7)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Text(entry.title)
                    .font(.system(size: 14, weight: .semibold, design: .serif))
                    .lineLimit(2)
                    .minimumScaleFactor(0.76)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var inlineAccessoryView: some View {
        Text("\(entry.dayNumber) \(entry.month) · \(entry.title)")
            .lineLimit(1)
    }

    private var circularAccessoryView: some View {
        VStack(spacing: -2) {
            Text(entry.dayNumber)
                .font(.system(size: 25, weight: .semibold, design: .serif))
            Text(entry.month)
                .font(.system(size: 8, weight: .bold))
                .tracking(0.8)
        }
        .widgetAccentable()
    }

    private var dateHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("\(entry.dayNumber) \(entry.month)")
                .font(.system(size: 10, weight: .semibold))
                .tracking(1.35)

            Spacer(minLength: 6)

            Text(entry.weekday)
                .font(.system(size: 9, weight: .medium))
                .tracking(0.9)
        }
        .foregroundStyle(entry.palette.ink.opacity(0.48))
    }

    private var wordmark: some View {
        HStack(spacing: 6) {
            WhaDayWidgetMark(color: entry.palette.ink)
                .frame(width: 12, height: 12)

            Text("WHADAY")
                .font(.system(size: 9, weight: .semibold))
                .tracking(1.45)
                .foregroundStyle(entry.palette.ink.opacity(0.82))
        }
    }

    private func accentRule(width: CGFloat) -> some View {
        Rectangle()
            .fill(entry.palette.accent)
            .frame(width: width, height: 2)
            .widgetAccentable()
            .accessibilityHidden(true)
    }
}

private struct WhaDayWidgetMark: View {
    let color: Color

    var body: some View {
        ZStack {
            Rectangle()
                .fill(color)
                .frame(width: 10, height: 1)
                .offset(y: -4)
            Rectangle()
                .fill(color)
                .frame(width: 1, height: 10)
                .offset(x: -4)
            Rectangle()
                .fill(color)
                .frame(width: 3, height: 3)
                .offset(x: 2, y: 2)
        }
        .frame(width: 12, height: 12)
        .accessibilityHidden(true)
    }
}

@main
struct WhaDayWidgetBundle: WidgetBundle {
    var body: some Widget {
        WhaDayWidget()
        SharedSpaceCountdownWidget()
    }
}

struct WhaDayWidget: Widget {
    let kind = "WhaDayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WhaDayProvider()) { entry in
            WhaDayWidgetView(entry: entry)
        }
        .configurationDisplayName("WhaDay")
        .description("Keep today's day close.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryRectangular,
            .accessoryInline,
            .accessoryCircular,
        ])
    }
}

struct SharedSpaceEntry: TimelineEntry {
    let date: Date
    let upcoming: UpcomingSharedEventData?
    let language: String
}

struct SharedSpaceProvider: TimelineProvider {
    func placeholder(in context: Context) -> SharedSpaceEntry {
        SharedSpaceEntry(
            date: Date(),
            upcoming: UpcomingSharedEventData(
                spaceID: "sample",
                spaceTitle: "Bizim Günümüz",
                spaceEmoji: "❤️",
                eventTitle: "Marmaris Tatili",
                eventEmoji: "🏖️",
                month: 9,
                day: 15,
                daysRemaining: 12
            ),
            language: "tr"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SharedSpaceEntry) -> Void) {
        let language = WidgetDayCatalog.languageCode(preferredLanguages: Locale.preferredLanguages)
        let data = SharedSpaceWidgetDataStore.load()
        completion(SharedSpaceEntry(date: Date(), upcoming: data, language: language))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SharedSpaceEntry>) -> Void) {
        let now = Date()
        let language = WidgetDayCatalog.languageCode(preferredLanguages: Locale.preferredLanguages)
        let data = SharedSpaceWidgetDataStore.load()
        let calendar = Calendar.autoupdatingCurrent
        completion(Timeline(
            entries: [SharedSpaceEntry(date: now, upcoming: data, language: language)],
            policy: .after(WidgetDayCatalog.nextLocalMidnight(after: now, calendar: calendar))
        ))
    }
}

struct SharedSpaceWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: SharedSpaceEntry

    private var palette: WidgetPalette {
        WidgetPalette.forTheme("culture")
    }

    var body: some View {
        content
            .widgetURL(targetURL)
    }

    private var targetURL: URL? {
        if let up = entry.upcoming {
            let dayID = String(format: "%02d-%02d", up.month, up.day)
            return URL(string: "whaday://day/\(dayID)")
        }
        return URL(string: "whaday://calendar")
    }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .systemMedium:
            mediumView
                .containerBackground(palette.paper, for: .widget)
        case .accessoryRectangular:
            rectangularAccessoryView
                .containerBackground(.clear, for: .widget)
        case .accessoryInline:
            inlineAccessoryView
                .containerBackground(.clear, for: .widget)
        case .accessoryCircular:
            circularAccessoryView
                .containerBackground(.clear, for: .widget)
        default:
            smallView
                .containerBackground(palette.paper, for: .widget)
        }
    }

    private var smallView: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let up = entry.upcoming {
                HStack(spacing: 4) {
                    Text(up.spaceEmoji)
                        .font(.system(size: 14))
                    Text(up.spaceTitle.uppercased())
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                        .foregroundStyle(palette.ink.opacity(0.55))
                        .lineLimit(1)
                }

                Spacer()

                Text(up.eventEmoji)
                    .font(.system(size: 28))
                    .padding(.bottom, 2)

                Text(up.eventTitle)
                    .font(.system(size: 15, weight: .bold, design: .serif))
                    .foregroundStyle(palette.ink)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)

                Spacer()

                countdownBadge(up.daysRemaining)
            } else {
                Text("❤️")
                    .font(.system(size: 24))
                Spacer()
                Text(entry.language == "tr" ? "Bizim Sayacımız" : "Our Countdown")
                    .font(.system(size: 14, weight: .bold, design: .serif))
                    .foregroundStyle(palette.ink)
                Text(entry.language == "tr" ? "Ortak bir gün ekle" : "Add a shared day")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(palette.ink.opacity(0.6))
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var mediumView: some View {
        HStack(alignment: .center, spacing: 16) {
            if let up = entry.upcoming {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text(up.spaceEmoji)
                            .font(.system(size: 14))
                        Text(up.spaceTitle.uppercased())
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                            .foregroundStyle(palette.ink.opacity(0.55))
                            .lineLimit(1)
                    }

                    Spacer()

                    HStack(spacing: 6) {
                        Text(up.eventEmoji)
                            .font(.system(size: 26))
                        Text(up.eventTitle)
                            .font(.system(size: 17, weight: .bold, design: .serif))
                            .foregroundStyle(palette.ink)
                            .lineLimit(2)
                    }

                    Spacer()

                    Text(formattedDate(month: up.month, day: up.day))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(palette.ink.opacity(0.6))
                }

                Spacer()

                VStack(spacing: 4) {
                    if up.daysRemaining == 0 {
                        Text("🎉")
                            .font(.system(size: 32))
                        Text(entry.language == "tr" ? "BUGÜN!" : "TODAY!")
                            .font(.system(size: 14, weight: .black))
                            .foregroundStyle(palette.accent)
                    } else {
                        Text("\(up.daysRemaining)")
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundStyle(palette.ink)
                        Text(entry.language == "tr" ? "GÜN KALDI" : "DAYS LEFT")
                            .font(.system(size: 9, weight: .black, design: .monospaced))
                            .foregroundStyle(palette.ink.opacity(0.5))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(palette.ink.opacity(0.06))
                .clipShape(Rectangle())
                .overlay(alignment: .leading) {
                    Rectangle()
                        .fill(palette.accent)
                        .frame(width: 2)
                }
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    Text("❤️ " + (entry.language == "tr" ? "Bizim Sayacımız" : "Our Countdown"))
                        .font(.system(size: 16, weight: .bold, design: .serif))
                        .foregroundStyle(palette.ink)
                    Text(entry.language == "tr" ? "Çiftin veya arkadaşlarınla ortak günlerini ve canlı sayacını burada gör." : "See your shared days and countdown here.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(palette.ink.opacity(0.6))
                }
            }
        }
    }

    private var rectangularAccessoryView: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let up = entry.upcoming {
                HStack(spacing: 4) {
                    Text(up.spaceEmoji)
                    Text(up.spaceTitle)
                        .font(.system(size: 11, weight: .bold))
                        .lineLimit(1)
                }
                Text("\(up.eventEmoji) \(up.eventTitle)")
                    .font(.system(size: 12, weight: .semibold))
                    .lineLimit(1)
                Text(up.daysRemaining == 0 ? (entry.language == "tr" ? "BUGÜN! 🎉" : "TODAY! 🎉") : (entry.language == "tr" ? "\(up.daysRemaining) gün kaldı" : "\(up.daysRemaining) days left"))
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.secondary)
            } else {
                Text("❤️ Bizim Sayacımız")
                    .font(.system(size: 12, weight: .bold))
                Text(entry.language == "tr" ? "Henüz gün eklenmedi" : "No days yet")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private var inlineAccessoryView: some View {
        if let up = entry.upcoming {
            Text("\(up.spaceEmoji) \(up.eventTitle): \(up.daysRemaining == 0 ? (entry.language == "tr" ? "Bugün!" : "Today!") : "\(up.daysRemaining)g")")
        } else {
            Text("❤️ Bizim Sayacımız")
        }
    }

    @ViewBuilder
    private var circularAccessoryView: some View {
        if let up = entry.upcoming {
            VStack(spacing: 0) {
                Text(up.spaceEmoji)
                    .font(.system(size: 12))
                Text("\(up.daysRemaining)")
                    .font(.system(size: 16, weight: .black))
                Text(entry.language == "tr" ? "GÜN" : "DAYS")
                    .font(.system(size: 8, weight: .bold))
            }
        } else {
            Text("❤️")
        }
    }

    private func countdownBadge(_ days: Int) -> some View {
        HStack(spacing: 4) {
            if days == 0 {
                Text(entry.language == "tr" ? "BUGÜN! 🎉" : "TODAY! 🎉")
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(palette.paper)
            } else if days == 1 {
                Text(entry.language == "tr" ? "YARIN" : "TOMORROW")
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(palette.paper)
            } else {
                Text("\(days)")
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(palette.paper)
                Text(entry.language == "tr" ? "GÜN KALDI" : "DAYS LEFT")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundStyle(palette.paper.opacity(0.85))
            }
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(palette.accent)
        .clipShape(Rectangle())
        .overlay(alignment: .bottom) {
            Rectangle().fill(palette.ink.opacity(0.24)).frame(height: 1)
        }
    }

    private func formattedDate(month: Int, day: Int) -> String {
        var comps = DateComponents()
        comps.month = month
        comps.day = day
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: entry.language == "tr" ? "tr_TR" : "en_US")
        formatter.dateFormat = "d MMMM"
        let date = Calendar.current.date(from: comps) ?? Date()
        return formatter.string(from: date)
    }
}

struct SharedSpaceCountdownWidget: Widget {
    let kind = "SharedSpaceWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SharedSpaceProvider()) { entry in
            SharedSpaceWidgetView(entry: entry)
        }
        .configurationDisplayName("Bizim Sayacımız")
        .description("Çiftin veya arkadaş grubunla ortak günün canlı geri sayımı.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryRectangular,
            .accessoryInline,
            .accessoryCircular,
        ])
    }
}

#Preview(as: .systemSmall) {
    WhaDayWidget()
} timeline: {
    WhaDayEntry(
        date: .now,
        dayID: "08-13",
        symbol: "✦",
        title: "Dünya Solaklar Günü",
        palette: .forTheme("fun"),
        language: "tr",
        sensitivity: .standard
    )
}

#Preview(as: .systemMedium) {
    WhaDayWidget()
} timeline: {
    WhaDayEntry(
        date: .now,
        dayID: "08-13",
        symbol: "✦",
        title: "Dünya Solaklar Günü",
        palette: .forTheme("fun"),
        language: "tr",
        sensitivity: .standard
    )
}

private extension Color {
    init?(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        guard cleaned.count == 6, let value = Int(cleaned, radix: 16) else { return nil }
        self.init(
            red: Double((value >> 16) & 0xff) / 255,
            green: Double((value >> 8) & 0xff) / 255,
            blue: Double(value & 0xff) / 255
        )
    }
}
