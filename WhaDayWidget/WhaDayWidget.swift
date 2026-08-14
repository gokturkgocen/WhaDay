import SwiftUI
import WidgetKit

struct WidgetPalette {
    let paper: Color
    let ink: Color
    let secondary: Color
    let accent: Color

    static func forTheme(_ theme: String) -> WidgetPalette {
        let values: (String, String, String, String)
        switch theme {
        case "nature": values = ("#B9EA76", "#111218", "#E5FF9B", "#78D46E")
        case "science": values = ("#8BB8FF", "#111218", "#7FF0FF", "#668CFF")
        case "peace": values = ("#91D9FF", "#111218", "#C5A7FF", "#6ABEFF")
        case "culture": values = ("#FFC857", "#111218", "#FFED9A", "#FFB13D")
        case "lifestyle": values = ("#FFB067", "#111218", "#FFE16A", "#FF8D58")
        case "health": values = ("#7FE5D1", "#111218", "#B8FFEA", "#49CEB5")
        case "social", "community": values = ("#C5A7FF", "#111218", "#FF9ED6", "#A77CFF")
        case "diversity": values = ("#FF9BD2", "#111218", "#FFE36A", "#CA7DFF")
        case "sport", "fun": values = ("#75DBFF", "#111218", "#C5FF5A", "#59BEFF")
        default: values = ("#B5A6FF", "#111218", "#D9FF66", "#8F86FF")
        }
        return WidgetPalette(
            paper: Color(hex: values.0) ?? .white,
            ink: Color(hex: values.1) ?? .black,
            secondary: Color(hex: values.2) ?? .green,
            accent: Color(hex: values.3) ?? .purple
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

    var eyebrow: String {
        if language == "tr" {
            return sensitivity == .standard ? "BUGÜNÜN BAHANESİ" : "BUGÜNÜN NOTU"
        }
        return sensitivity == .standard ? "TODAY'S EXCUSE" : "TODAY'S NOTE"
    }

    var accessibilitySummary: String {
        "\(eyebrow.capitalized). \(title)"
    }
}

struct WhaDayProvider: TimelineProvider {
    func placeholder(in context: Context) -> WhaDayEntry {
        WhaDayEntry(
            date: Date(),
            dayID: "08-13",
            symbol: "✋",
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
        Group {
            if family == .accessoryRectangular {
                accessoryView
                    .containerBackground(.clear, for: .widget)
            } else {
                homeScreenView
                    .containerBackground(Color(hex: "#0B0D12") ?? .black, for: .widget)
            }
        }
        .widgetURL(entry.dayID.flatMap { URL(string: "whaday://day/\($0)") })
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(entry.accessibilitySummary)
        .accessibilityHint(entry.language == "tr" ? "Günü WhaDay'de açar" : "Opens the day in WhaDay")
    }

    private var homeScreenView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                WhaDayWidgetMark(color: entry.palette.secondary)
                Text("WHADAY")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .tracking(0.7)
                Spacer()
                Text(entry.symbol).font(.system(size: 24))
            }
            .foregroundStyle(Color(hex: "#F4F2EA") ?? .white)

            Spacer(minLength: 2)

            VStack(alignment: .leading, spacing: 5) {
                Text(entry.eyebrow)
                    .font(.system(size: 8, weight: .black, design: .rounded))
                    .tracking(0.9)
                    .opacity(0.68)

                Text(entry.title)
                    .font(.system(size: family == .systemSmall ? 17 : 21, weight: .black, design: .rounded))
                    .tracking(-0.5)
                    .lineLimit(family == .systemSmall ? 3 : 2)
                    .minimumScaleFactor(0.68)
            }
            .foregroundStyle(entry.palette.ink)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [entry.palette.paper, entry.palette.accent],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .padding(14)
    }

    private var accessoryView: some View {
        HStack(spacing: 8) {
            Text(entry.symbol)
                .font(.system(size: 22))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.eyebrow)
                    .font(.system(size: 8, weight: .black, design: .rounded))
                    .tracking(0.6)
                    .lineLimit(1)
                Text(entry.title)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .widgetAccentable()
    }
}

private struct WhaDayWidgetMark: View {
    let color: Color

    var body: some View {
        ZStack {
            ForEach(0..<6, id: \.self) { index in
                Capsule()
                    .fill(color)
                    .frame(width: 3, height: 11)
                    .offset(y: -4)
                    .rotationEffect(.degrees(Double(index) * 60))
            }
            Circle().fill(color).frame(width: 3, height: 3)
        }
        .frame(width: 18, height: 18)
        .accessibilityHidden(true)
    }
}

@main
struct WhaDayWidget: Widget {
    let kind = "WhaDayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WhaDayProvider()) { entry in
            WhaDayWidgetView(entry: entry)
        }
        .configurationDisplayName("WhaDay")
        .description("Open today's day and share it with someone.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
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
