import Foundation

enum DayDiscoveryFilter: String, CaseIterable, Identifiable {
    case all
    case sendable
    case official
    case playful
    case saved

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .all: "calendar"
        case .sendable: "paperplane.fill"
        case .official: "checkmark.seal.fill"
        case .playful: "sparkles"
        case .saved: "bookmark.fill"
        }
    }

    func title(language: String) -> String {
        let isTurkish = language == "tr"
        switch self {
        case .all: return isTurkish ? "Tümü" : "All"
        case .sendable: return isTurkish ? "Atmalık" : "Sendable"
        case .official: return isTurkish ? "Resmî" : "Official"
        case .playful: return isTurkish ? "Eğlenceli" : "Playful"
        case .saved: return isTurkish ? "Kaydedilen" : "Saved"
        }
    }

    func includes(_ event: DayEvent, savedIDs: Set<String>) -> Bool {
        switch self {
        case .all:
            return true
        case .sendable:
            return event.sensitivity == .standard && event.shareability >= 4
        case .official:
            return event.authority == .official
        case .playful:
            return event.sensitivity == .standard && event.contentCategory == .playful
        case .saved:
            return savedIDs.contains(event.id)
        }
    }
}

enum DayDiscoveryQuery {
    static func apply(
        to events: [DayEvent],
        searchText: String,
        filter: DayDiscoveryFilter,
        savedIDs: Set<String>,
        locale: Locale
    ) -> [DayEvent] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return events.filter { event in
            guard filter.includes(event, savedIDs: savedIDs) else { return false }
            guard !query.isEmpty else { return true }
            return event.title.range(
                of: query,
                options: [.caseInsensitive, .diacriticInsensitive],
                locale: locale
            ) != nil
        }
    }
}
