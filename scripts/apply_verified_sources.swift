#!/usr/bin/env swift

import Foundation

// Source checks completed against primary institutional pages on 2026-08-14.
// This script updates only source provenance. It deliberately does not mark
// user-facing editorial copy as curated.

private struct VerifiedSource {
    let organization: String
    let url: String
}

private let verified: [String: VerifiedSource] = [
    "01-04": .init(organization: "United Nations", url: "https://www.un.org/en/observances/braille-day"),
    "01-14": .init(organization: "UNESCO", url: "https://www.unesco.org/en/days/world-logic"),
    "01-24": .init(organization: "UNESCO", url: "https://www.unesco.org/en/days/education"),
    "01-27": .init(organization: "UNESCO", url: "https://www.unesco.org/en/days/holocaust-remembrance"),
    "02-11": .init(organization: "UNESCO", url: "https://www.unesco.org/en/days/women-girls-science"),
    "02-13": .init(organization: "UNESCO", url: "https://www.unesco.org/en/days/world-radio"),
    "02-17": .init(organization: "United Nations", url: "https://www.un.org/en/observances/tourism-resilience-day"),
    "02-20": .init(organization: "United Nations", url: "https://www.un.org/en/observances/social-justice-day"),
    "02-21": .init(organization: "UNESCO", url: "https://www.unesco.org/en/days/mother-language"),
    "03-20": .init(organization: "United Nations", url: "https://www.un.org/en/observances/happiness-day"),
    "03-22": .init(organization: "UNESCO", url: "https://www.unesco.org/en/days/world-water"),
    "04-02": .init(organization: "United Nations", url: "https://www.un.org/en/observances/autism-day"),
    "04-07": .init(organization: "World Health Organization", url: "https://www.who.int/campaigns/world-health-day"),
    "04-22": .init(organization: "United Nations", url: "https://www.un.org/en/observances/earth-day"),
    "04-23": .init(organization: "UNESCO", url: "https://www.unesco.org/en/days/world-book-and-copyright"),
    "05-03": .init(organization: "UNESCO", url: "https://www.unesco.org/en/days/press-freedom"),
    "05-20": .init(organization: "Food and Agriculture Organization of the United Nations", url: "https://www.fao.org/world-bee-day/en"),
    "06-05": .init(organization: "UNESCO", url: "https://www.unesco.org/en/days/environment"),
    "06-08": .init(organization: "UNESCO", url: "https://www.unesco.org/en/days/oceans"),
    "06-14": .init(organization: "World Health Organization", url: "https://www.who.int/campaigns/world-blood-donor-day"),
    "06-17": .init(organization: "United Nations", url: "https://www.un.org/en/observances/desertification-day"),
    "06-20": .init(organization: "United Nations", url: "https://www.un.org/en/observances/refugee-day"),
    "06-21": .init(organization: "United Nations", url: "https://www.un.org/en/observances/yoga-day"),
    "06-23": .init(organization: "United Nations", url: "https://www.un.org/en/observances/international-widows-day"),
    "07-15": .init(organization: "United Nations", url: "https://www.un.org/en/observances/world-youth-skills-day"),
    "08-09": .init(organization: "UNESCO", url: "https://www.unesco.org/en/days/worlds-indigenous-peoples"),
    "08-12": .init(organization: "UNESCO", url: "https://www.unesco.org/en/days/youth"),
    "08-19": .init(organization: "United Nations", url: "https://www.un.org/en/observances/humanitarian-day"),
    "09-09": .init(organization: "UNESCO", url: "https://www.unesco.org/en/days/protect-education-attack"),
    "09-12": .init(organization: "United Nations", url: "https://www.un.org/en/observances/south-south-cooperation-day"),
    "09-21": .init(organization: "UNESCO", url: "https://www.unesco.org/en/days/peace"),
    "10-10": .init(organization: "World Health Organization", url: "https://www.who.int/campaigns/world-mental-health-day"),
    "10-11": .init(organization: "UNESCO", url: "https://www.unesco.org/en/days/girl-child"),
    "10-15": .init(organization: "United Nations", url: "https://www.un.org/en/observances/rural-women-day"),
    "10-16": .init(organization: "United Nations", url: "https://www.un.org/en/observances/world-food-day"),
    "10-24": .init(organization: "United Nations", url: "https://www.un.org/en/observances/un-day"),
    "11-18": .init(organization: "United Nations", url: "https://www.un.org/en/observances/child-sexual-exploitation-prevention-and-healing-day"),
    "12-01": .init(organization: "World Health Organization", url: "https://www.who.int/campaigns/world-aids-day"),
    "12-03": .init(organization: "UNESCO", url: "https://www.unesco.org/en/days/international-day-persons-disabilities"),
    "12-10": .init(organization: "UNESCO", url: "https://www.unesco.org/en/days/human-rights")
]

private let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
private let ledgerURL = root.appendingPathComponent("WhaDayNative/Data/metadata.json")
private let data = try Data(contentsOf: ledgerURL)
guard var records = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
    fatalError("metadata.json is not an array of objects")
}

private let ids = Set(records.compactMap { $0["id"] as? String })
private let missing = Set(verified.keys).subtracting(ids)
guard missing.isEmpty else {
    fatalError("Verified IDs missing from metadata: \(missing.sorted())")
}

var updated = 0
for index in records.indices {
    guard let id = records[index]["id"] as? String, let source = verified[id] else { continue }
    guard records[index]["authority"] as? String == "official" else {
        fatalError("Refusing to attach an official source to non-official record \(id)")
    }
    records[index]["source"] = [
        "organization": source.organization,
        "url": source.url,
        "checkedAt": "2026-08-14"
    ]
    updated += 1
}

guard updated == verified.count else {
    fatalError("Expected to update \(verified.count) sources, updated \(updated)")
}

let output = try JSONSerialization.data(
    withJSONObject: records,
    options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
)
try output.write(to: ledgerURL, options: .atomic)
print("Applied \(updated) verified primary-source records")
