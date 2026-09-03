import Foundation

enum WidgetDaySensitivity: String, Codable, Equatable {
    case standard
    case considerate
    case remembrance
}

struct WidgetDayContent: Equatable {
    let id: String
    let month: Int
    let day: Int
    let title: String
    let symbol: String
    let themeKey: String
    let sensitivity: WidgetDaySensitivity
}

enum WidgetDayCatalog {
    private struct LocalizedRecord: Codable {
        let id: String
        let month: Int
        let day: Int
        let title: String
        let emoji: String
        let category: String
    }

    private struct MetadataRecord: Codable {
        let id: String
        let category: String
        let sensitivity: WidgetDaySensitivity
        let symbol: String
    }

    static func languageCode(preferredLanguages: [String]) -> String {
        guard let preferred = preferredLanguages.first else { return "en" }
        return preferred.lowercased().hasPrefix("tr") ? "tr" : "en"
    }

    static func decode(localizedData: Data, metadataData: Data?) throws -> [WidgetDayContent] {
        let records = try JSONDecoder().decode([LocalizedRecord].self, from: localizedData)
        let metadata = metadataData
            .flatMap { try? JSONDecoder().decode([MetadataRecord].self, from: $0) }
            .map { Dictionary(uniqueKeysWithValues: $0.map { ($0.id, $0) }) } ?? [:]

        return records.map { record in
            let details = metadata[record.id]
            return WidgetDayContent(
                id: record.id,
                month: record.month,
                day: record.day,
                title: record.title,
                symbol: details?.symbol ?? displaySymbol(raw: record.emoji),
                themeKey: themeKey(metadataCategory: details?.category, legacyCategory: record.category),
                sensitivity: details?.sensitivity ?? .standard
            )
        }
    }

    static func event(
        at date: Date,
        calendar: Calendar,
        events: [WidgetDayContent]
    ) -> WidgetDayContent? {
        let components = calendar.dateComponents([.month, .day], from: date)
        return events.first { $0.month == components.month && $0.day == components.day }
    }

    static func nextLocalMidnight(after date: Date, calendar: Calendar) -> Date {
        let start = calendar.startOfDay(for: date)
        return calendar.date(byAdding: .day, value: 1, to: start)
            ?? date.addingTimeInterval(60 * 60)
    }

    private static func displaySymbol(raw: String) -> String {
        raw == "🔔" ? "✦" : raw
    }

    private static func themeKey(metadataCategory: String?, legacyCategory: String) -> String {
        switch metadataCategory {
        case "relationships": return "social"
        case "food-and-drink": return "lifestyle"
        case "animals-and-nature": return "nature"
        case "culture-and-arts", "celebrations": return "culture"
        case "science-and-curiosity": return "science"
        case "playful": return "fun"
        case "health-and-awareness": return "health"
        case "professions": return "community"
        case "remembrance": return "peace"
        case "sport-and-movement": return "sport"
        case "civil-society": return "diversity"
        case .some: return "default"
        case .none: return legacyCategory
        }
    }
}

struct UpcomingSharedEventData: Codable, Equatable, Sendable {
    let spaceID: String
    let spaceTitle: String
    let spaceEmoji: String
    let eventTitle: String
    let eventEmoji: String
    let month: Int
    let day: Int
    let daysRemaining: Int
}

enum SharedSpaceWidgetDataStore {
    static let appGroupID = "group.com.gokturkgocen.whadayapp"
    static let storageKey = "widget_upcoming_shared_event"

    static func load() -> UpcomingSharedEventData? {
        guard
            let defaults = UserDefaults(suiteName: appGroupID),
            let data = defaults.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode(UpcomingSharedEventData.self, from: data)
        else {
            return nil
        }
        return decoded
    }

    static func save(_ event: UpcomingSharedEventData?) {
        guard let defaults = UserDefaults(suiteName: appGroupID) else { return }
        if let event = event, let data = try? JSONEncoder().encode(event) {
            defaults.set(data, forKey: storageKey)
        } else {
            defaults.removeObject(forKey: storageKey)
        }
    }
}
