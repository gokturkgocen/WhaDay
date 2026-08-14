import Foundation

struct DayEvent: Codable, Identifiable, Equatable {
    let id: String
    let month: Int
    let day: Int
    let title: String
    let description: String
    let emoji: String
    let category: String
    let sharingHook: String
    let metadata: DayMetadata?

    init(
        id: String,
        month: Int,
        day: Int,
        title: String,
        description: String,
        emoji: String,
        category: String,
        sharingHook: String,
        metadata: DayMetadata? = nil
    ) {
        self.id = id
        self.month = month
        self.day = day
        self.title = title
        self.description = description
        self.emoji = emoji
        self.category = category
        self.sharingHook = sharingHook
        self.metadata = metadata
    }

    var contentCategory: DayContentCategory {
        metadata?.category ?? .fromLegacy(category)
    }

    var themeCategoryKey: String { contentCategory.themeKey }
    var authority: DayAuthority { metadata?.authority ?? .editorial }
    var sensitivity: DaySensitivity { metadata?.sensitivity ?? .standard }
    var shareability: Int { metadata?.shareability ?? 3 }

    func attaching(_ metadata: DayMetadata?) -> DayEvent {
        DayEvent(
            id: id,
            month: month,
            day: day,
            title: title,
            description: description,
            emoji: emoji,
            category: category,
            sharingHook: sharingHook,
            metadata: metadata
        )
    }
}
