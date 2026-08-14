import SwiftUI
import WidgetKit

private let appGroupID = "group.com.gokturkgocen.whadayapp"

private struct WidgetDayEvent: Codable {
    let id: String
    let month: Int
    let day: Int
    let title: String
    let description: String
    let emoji: String
    let category: String
    let sharingHook: String
}

struct WhaDayEntry: TimelineEntry {
    let date: Date
    let dayID: String?
    let emoji: String
    let title: String
    let paper: Color
    let ink: Color
    let secondary: Color
    let accent: Color
    let language: String
}

struct WhaDayProvider: TimelineProvider {
    func placeholder(in context: Context) -> WhaDayEntry {
        WhaDayEntry(
            date: Date(), dayID: "08-13", emoji: "✋", title: "Dünya Solaklar Günü",
            paper: Color(hex: "#B5A6FF") ?? .purple,
            ink: Color(hex: "#111218") ?? .black,
            secondary: Color(hex: "#D9FF66") ?? .green,
            accent: Color(hex: "#8F86FF") ?? .purple,
            language: "tr"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (WhaDayEntry) -> Void) {
        completion(loadEntry(at: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WhaDayEntry>) -> Void) {
        let now = Date()
        let entry = loadEntry(at: now)
        let nextRefresh = Calendar.current.nextDate(
            after: now,
            matching: DateComponents(hour: 0, minute: 1),
            matchingPolicy: .nextTime
        ) ?? now.addingTimeInterval(60 * 60)
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }

    private func loadEntry(at date: Date) -> WhaDayEntry {
        let defaults = UserDefaults(suiteName: appGroupID)
        let components = Calendar.current.dateComponents([.month, .day], from: date)
        let storedDays = defaults?.data(forKey: "widgetDays")
            .flatMap { try? JSONDecoder().decode([WidgetDayEvent].self, from: $0) }
        let event = storedDays?.first { $0.month == components.month && $0.day == components.day }
        let palette = palette(for: event?.category)

        return WhaDayEntry(
            date: date,
            dayID: event?.id,
            emoji: displayEmoji(for: event),
            title: event?.title ?? defaults?.string(forKey: "widgetTitle") ?? "WhaDay",
            paper: Color(hex: defaults?.string(forKey: "widgetPaper") ?? palette.paper) ?? .white,
            ink: Color(hex: defaults?.string(forKey: "widgetInk") ?? palette.ink) ?? .black,
            secondary: Color(hex: defaults?.string(forKey: "widgetSecondary") ?? palette.secondary) ?? .orange,
            accent: Color(hex: defaults?.string(forKey: "widgetAccent") ?? palette.accent) ?? .red,
            language: defaults?.string(forKey: "widgetLanguage") ?? "en"
        )
    }

    private func displayEmoji(for event: WidgetDayEvent?) -> String {
        guard let event else { return "✦" }
        let curated = ["08-13": "✋", "08-08": "🐈", "08-26": "🐕", "10-01": "☕️", "10-31": "🎃"]
        if let symbol = curated[event.id] { return symbol }
        return event.emoji == "🔔" ? "✦" : event.emoji
    }

    private func palette(for category: String?) -> (paper: String, ink: String, secondary: String, accent: String) {
        switch category {
        case "nature", "growth": return ("#B9EA76", "#111218", "#E5FF9B", "#78D46E")
        case "science", "knowledge": return ("#8BB8FF", "#111218", "#7FF0FF", "#668CFF")
        case "peace", "reflection": return ("#91D9FF", "#111218", "#C5A7FF", "#6ABEFF")
        case "culture": return ("#FFC857", "#111218", "#FFED9A", "#FFB13D")
        default: return ("#B5A6FF", "#111218", "#D9FF66", "#8F86FF")
        }
    }
}

struct WhaDayWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: WhaDayEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                WhaDayWidgetMark(color: entry.secondary)
                Text("WHADAY")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .tracking(0.7)
                Spacer()
                Text(entry.emoji).font(.system(size: 24))
            }
            .foregroundStyle(Color(hex: "#F4F2EA") ?? .white)

            Spacer(minLength: 2)

            VStack(alignment: .leading, spacing: 5) {
                Text(entry.language == "tr" ? "BUGÜNÜN BAHANESİ" : "TODAY'S EXCUSE")
                    .font(.system(size: 8, weight: .black, design: .rounded))
                    .tracking(0.9)
                    .opacity(0.68)

                Text(entry.title)
                    .font(.system(size: family == .systemSmall ? 17 : 21, weight: .black, design: .rounded))
                    .tracking(-0.5)
                    .lineLimit(family == .systemSmall ? 3 : 2)
                    .minimumScaleFactor(0.68)
            }
            .foregroundStyle(entry.ink)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(LinearGradient(colors: [entry.paper, entry.accent], startPoint: .topLeading, endPoint: .bottomTrailing))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .padding(14)
        .containerBackground(Color(hex: "#0B0D12") ?? .black, for: .widget)
        .widgetURL(entry.dayID.flatMap { URL(string: "whaday://day/\($0)") })
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
        .description("Today's shareable excuse.")
        .supportedFamilies([.systemSmall, .systemMedium])
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
