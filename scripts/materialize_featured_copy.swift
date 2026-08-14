#!/usr/bin/env swift

import Foundation

// Materializes the 42 hand-written featured cards from EditorialContent.swift
// into the localized corpus and marks only those same reviewed records curated.

private struct LocalizedDay: Codable {
    let id: String
    let month: Int
    let day: Int
    var title: String
    var description: String
    var emoji: String
    var category: String
    var sharingHook: String
}

private struct FeaturedCopy {
    let id: String
    let trFact: String
    let trPrompt: String
    let enFact: String
    let enPrompt: String
}

private struct SourcePatch {
    let organization: String
    let url: String
}

private let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
private let editorialURL = root.appendingPathComponent("WhaDayNative/Models/EditorialContent.swift")
private let editorialSource = try String(contentsOf: editorialURL, encoding: .utf8)
private let marker = "private static let curated: [String: Pair]"
guard let markerRange = editorialSource.range(of: marker) else {
    fatalError("Could not find featured editorial dictionary")
}
private let featuredSource = String(editorialSource[markerRange.lowerBound...])
private let pattern = #"(?s)        \"([0-9]{2}-[0-9]{2})\": pair\(\s*trFact: \"([^\"]*)\",\s*trPrompt: \"([^\"]*)\",\s*trMessage: \"[^\"]*\",\s*enFact: \"([^\"]*)\",\s*enPrompt: \"([^\"]*)\","#
private let regex = try NSRegularExpression(pattern: pattern)
private let fullRange = NSRange(featuredSource.startIndex..., in: featuredSource)
private let matches = regex.matches(in: featuredSource, range: fullRange)

private func capture(_ match: NSTextCheckingResult, _ index: Int) -> String {
    guard let range = Range(match.range(at: index), in: featuredSource) else {
        fatalError("Malformed featured-copy capture")
    }
    return String(featuredSource[range])
}

private let featured = matches.map {
    FeaturedCopy(
        id: capture($0, 1),
        trFact: capture($0, 2),
        trPrompt: capture($0, 3),
        enFact: capture($0, 4),
        enPrompt: capture($0, 5)
    )
}
private let targetIDs = Set(featured.map(\.id))
guard featured.count == 42, targetIDs.count == featured.count else {
    fatalError("Expected 42 unique featured cards, extracted \(featured.count)")
}

private let officialSources: [String: SourcePatch] = [
    "03-20": .init(organization: "United Nations", url: "https://www.un.org/en/observances/happiness-day"),
    "05-20": .init(organization: "Food and Agriculture Organization of the United Nations", url: "https://www.fao.org/world-bee-day/en"),
    "05-21": .init(organization: "United Nations", url: "https://www.un.org/en/observances/tea-day"),
    "07-30": .init(organization: "United Nations", url: "https://www.un.org/en/observances/international-day-friendship"),
    "10-01": .init(organization: "United Nations", url: "https://www.un.org/en/observances/international-coffee-day"),
    "11-19": .init(organization: "United Nations", url: "https://www.un.org/en/observances/toilet-day")
]

private let relationships: Set<String> = ["01-21", "02-14", "03-20", "07-30", "11-13"]
private let foodAndDrink: Set<String> = ["02-05", "02-09", "03-06", "05-06", "05-21", "10-01", "10-25", "12-30"]
private let animalsAndNature: Set<String> = ["01-20", "03-16", "05-20", "08-08", "08-26", "09-24"]
private let cultureAndArts: Set<String> = ["01-02", "01-18", "03-09", "05-04", "07-17", "07-31", "10-21", "12-23"]
private let scienceAndCuriosity: Set<String> = ["01-29", "03-14"]
private let celebrations: Set<String> = ["04-01", "10-31", "12-31"]
private let civilSociety: Set<String> = ["11-19"]
private let explicitlyCategorized = relationships
    .union(foodAndDrink)
    .union(animalsAndNature)
    .union(cultureAndArts)
    .union(scienceAndCuriosity)
    .union(celebrations)
    .union(civilSociety)
private let playful = targetIDs.subtracting(explicitlyCategorized)
guard explicitlyCategorized.intersection(playful).isEmpty else {
    fatalError("Featured categories overlap")
}

private func quote(_ value: String) -> String {
    String(data: try! JSONEncoder().encode(value), encoding: .utf8)!
}

private func render(_ days: [LocalizedDay]) -> String {
    let objects = days.map { day in
        """
          {
            "id": \(quote(day.id)),
            "month": \(day.month),
            "day": \(day.day),
            "title": \(quote(day.title)),
            "description": \(quote(day.description)),
            "emoji": \(quote(day.emoji)),
            "category": \(quote(day.category)),
            "sharingHook": \(quote(day.sharingHook))
          }
        """
    }
    return "[\n" + objects.joined(separator: ",\n") + "\n]\n"
}

private func materializeLocalized(_ language: String) throws {
    let url = root.appendingPathComponent("WhaDayNative/Data/\(language).json")
    var days = try JSONDecoder().decode([LocalizedDay].self, from: Data(contentsOf: url))
    guard days.count == 366, targetIDs.isSubset(of: Set(days.map(\.id))) else {
        fatalError("\(language) catalog is missing featured records")
    }

    let byID = Dictionary(uniqueKeysWithValues: featured.map { ($0.id, $0) })
    for index in days.indices {
        guard let copy = byID[days[index].id] else { continue }
        days[index].description = language == "tr" ? copy.trFact : copy.enFact
        days[index].sharingHook = language == "tr" ? copy.trPrompt : copy.enPrompt

        if days[index].id == "02-29" {
            let oldTitle = language == "tr" ? "Nadir Hastalıklar Günü" : "Rare Disease Day"
            let newTitle = language == "tr" ? "Fazladan Gün" : "Bonus Day"
            guard days[index].title == oldTitle || days[index].title == newTitle else {
                fatalError("Refusing to replace unexpected 02-29 title: \(days[index].title)")
            }
            days[index].title = newTitle
            days[index].emoji = "🗓️"
            days[index].category = "fun"
        }
    }
    try render(days).write(to: url, atomically: true, encoding: .utf8)
}

private func category(for id: String) -> String {
    if relationships.contains(id) { return "relationships" }
    if foodAndDrink.contains(id) { return "food-and-drink" }
    if animalsAndNature.contains(id) { return "animals-and-nature" }
    if cultureAndArts.contains(id) { return "culture-and-arts" }
    if scienceAndCuriosity.contains(id) { return "science-and-curiosity" }
    if celebrations.contains(id) { return "celebrations" }
    if civilSociety.contains(id) { return "civil-society" }
    if playful.contains(id) { return "playful" }
    fatalError("Missing category for \(id)")
}

private func materializeMetadata() throws {
    let url = root.appendingPathComponent("WhaDayNative/Data/metadata.json")
    guard var records = try JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [[String: Any]] else {
        fatalError("metadata.json is not an array")
    }
    guard records.count == 366, targetIDs.isSubset(of: Set(records.compactMap { $0["id"] as? String })) else {
        fatalError("Metadata catalog is missing featured records")
    }

    var updated = 0
    for index in records.indices {
        guard let id = records[index]["id"] as? String, targetIDs.contains(id) else { continue }
        records[index]["reviewState"] = "curated"
        records[index]["category"] = category(for: id)
        records[index]["sensitivity"] = "standard"
        records[index]["shareability"] = id == "11-19" ? 4 : 5

        if id == "02-29" {
            records[index]["authority"] = "editorial"
            records[index]["scope"] = "whaday-editorial"
            records[index]["audience"] = ["friend"]
            records[index]["symbol"] = "🗓️"
            records[index].removeValue(forKey: "source")
        } else if let source = officialSources[id] {
            records[index]["authority"] = "official"
            records[index]["scope"] = "international"
            records[index]["source"] = [
                "organization": source.organization,
                "url": source.url,
                "checkedAt": "2026-08-14"
            ]
        } else {
            records[index]["authority"] = "cultural"
            records[index]["scope"] = "global-cultural"
            records[index].removeValue(forKey: "source")
        }

        if relationships.contains(id) {
            records[index]["audience"] = ["friend", "family", "partner"]
        } else if foodAndDrink.contains(id) {
            records[index]["audience"] = ["food-companion", "friend"]
        } else if animalsAndNature.contains(id) {
            records[index]["audience"] = ["friend", "community"]
        } else {
            records[index]["audience"] = ["friend"]
        }
        updated += 1
    }
    guard updated == 42 else { fatalError("Expected 42 metadata updates, wrote \(updated)") }

    let output = try JSONSerialization.data(
        withJSONObject: records,
        options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
    )
    try output.write(to: url, options: .atomic)
}

try materializeLocalized("tr")
try materializeLocalized("en")
try materializeMetadata()
print("Materialized and curated 42 featured share cards")
