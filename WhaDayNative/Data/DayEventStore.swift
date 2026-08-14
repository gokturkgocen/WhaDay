import Foundation

enum DayEventStore {
    static let supportedLanguages: Set<String> = ["en", "tr"]

    static let language: String = {
        let preferred = Locale.preferredLanguages.first ?? "en"
        let code = String(preferred.prefix(2)).lowercased()
        return supportedLanguages.contains(code) ? code : "en"
    }()

    static let dateLocale: Locale = language == "tr" ? Locale(identifier: "tr_TR") : Locale(identifier: "en_US")

    static let days: [DayEvent] = load(language)

    static func today() -> DayEvent? {
        let now = Date()
        let calendar = Calendar.current
        let month = calendar.component(.month, from: now)
        let day = calendar.component(.day, from: now)
        return event(month: month, day: day)
    }

    static func event(month: Int, day: Int) -> DayEvent? {
        days.first { $0.month == month && $0.day == day }
    }

    private static func load(_ language: String) -> [DayEvent] {
        guard
            let url = Bundle.main.url(forResource: language, withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let events = try? JSONDecoder().decode([DayEvent].self, from: data)
        else {
            return []
        }
        return events.map { $0.attaching(DayMetadataStore.byID[$0.id]) }
    }
}
