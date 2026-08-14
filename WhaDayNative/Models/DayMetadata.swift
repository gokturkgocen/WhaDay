import Foundation

enum DayAuthority: String, Codable, CaseIterable {
    case official
    case cultural
    case editorial
}

enum DayContentCategory: String, Codable, CaseIterable {
    case relationships
    case foodAndDrink = "food-and-drink"
    case animalsAndNature = "animals-and-nature"
    case cultureAndArts = "culture-and-arts"
    case scienceAndCuriosity = "science-and-curiosity"
    case playful
    case healthAndAwareness = "health-and-awareness"
    case professions
    case remembrance
    case celebrations
    case sportAndMovement = "sport-and-movement"
    case civilSociety = "civil-society"

    var themeKey: String {
        switch self {
        case .relationships: "social"
        case .foodAndDrink: "lifestyle"
        case .animalsAndNature: "nature"
        case .cultureAndArts: "culture"
        case .scienceAndCuriosity: "science"
        case .playful: "fun"
        case .healthAndAwareness: "health"
        case .professions: "community"
        case .remembrance: "peace"
        case .celebrations: "culture"
        case .sportAndMovement: "sport"
        case .civilSociety: "diversity"
        }
    }

    static func fromLegacy(_ value: String) -> DayContentCategory {
        switch value {
        case "social", "community": .relationships
        case "lifestyle": .foodAndDrink
        case "nature": .animalsAndNature
        case "culture", "creative": .cultureAndArts
        case "science", "knowledge", "tech": .scienceAndCuriosity
        case "fun", "motivation", "action": .playful
        case "health", "wellness": .healthAndAwareness
        case "sport": .sportAndMovement
        case "peace", "reflection": .remembrance
        case "diversity": .civilSociety
        case "mindfulness", "growth": .healthAndAwareness
        default: .playful
        }
    }
}

enum DaySensitivity: String, Codable, CaseIterable {
    case standard
    case considerate
    case remembrance

    var blocksEngagementPromotion: Bool { self != .standard }
}

enum DayReviewState: String, Codable, CaseIterable {
    case needsEditorialReview = "needs-editorial-review"
    case needsSafetyReview = "needs-safety-review"
    case sourceLinked = "source-linked"
    case curated
    case verified
}

struct DaySource: Codable, Equatable {
    let organization: String
    let url: URL
    let checkedAt: String?
}

struct DayMetadata: Codable, Equatable, Identifiable {
    let id: String
    let authority: DayAuthority
    let category: DayContentCategory
    let sensitivity: DaySensitivity
    let shareability: Int
    let audience: [String]
    let symbol: String
    let reviewState: DayReviewState
    let scope: String?
    let source: DaySource?

    var hasValidShareability: Bool { (1...5).contains(shareability) }
    var canBePromotedForEngagement: Bool {
        sensitivity == .standard && shareability >= 3
    }
}

enum DayMetadataStore {
    static let entries: [DayMetadata] = load()
    static let byID: [String: DayMetadata] = Dictionary(
        uniqueKeysWithValues: entries.map { ($0.id, $0) }
    )

    private static func load() -> [DayMetadata] {
        guard
            let url = Bundle.main.url(forResource: "metadata", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let metadata = try? JSONDecoder().decode([DayMetadata].self, from: data)
        else {
            return []
        }
        return metadata
    }
}
