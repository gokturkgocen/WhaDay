import SwiftUI
import WidgetKit

private let appGroupID = "group.com.gokturkgocen.whadayapp"

struct WhaDayEntry: TimelineEntry {
    let date: Date
    let emoji: String
    let title: String
    let accent: Color
}

struct WhaDayProvider: TimelineProvider {
    func placeholder(in context: Context) -> WhaDayEntry {
        WhaDayEntry(date: Date(), emoji: "✨", title: "WhaDay", accent: .purple)
    }

    func getSnapshot(in context: Context, completion: @escaping (WhaDayEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WhaDayEntry>) -> Void) {
        completion(Timeline(entries: [loadEntry()], policy: .after(Date().addingTimeInterval(60 * 60))))
    }

    private func loadEntry() -> WhaDayEntry {
        let defaults = UserDefaults(suiteName: appGroupID)
        let emoji = defaults?.string(forKey: "widgetEmoji") ?? "✨"
        let title = defaults?.string(forKey: "widgetTitle") ?? "WhaDay"
        let accentHex = defaults?.string(forKey: "widgetAccent") ?? "#c084fc"

        return WhaDayEntry(
            date: Date(),
            emoji: emoji,
            title: title,
            accent: Color(hex: accentHex) ?? .purple
        )
    }
}

struct WhaDayWidgetView: View {
    let entry: WhaDayEntry

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [entry.accent.opacity(0.95), Color(red: 0.06, green: 0.05, blue: 0.16)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 8) {
                Text(entry.emoji)
                    .font(.system(size: 38))

                Spacer(minLength: 0)

                Text(entry.title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(3)
                    .minimumScaleFactor(0.75)

                Text("WhaDay")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.65))
            }
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
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
        .description("Shows today's WhaDay.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

private extension Color {
    init?(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        guard cleaned.count == 6, let value = Int(cleaned, radix: 16) else {
            return nil
        }

        self.init(
            red: Double((value >> 16) & 0xff) / 255,
            green: Double((value >> 8) & 0xff) / 255,
            blue: Double(value & 0xff) / 255
        )
    }
}
