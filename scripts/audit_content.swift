#!/usr/bin/env swift

import Foundation

private struct LocalizedDay: Decodable {
    let id: String
    let month: Int
    let day: Int
    let title: String
    let description: String
    let emoji: String
    let category: String
    let sharingHook: String
}

private struct Source: Decodable {
    let organization: String
    let url: String
    let checkedAt: String?
}

private struct Metadata: Decodable {
    let id: String
    let authority: String
    let category: String
    let sensitivity: String
    let shareability: Int
    let audience: [String]
    let symbol: String
    let reviewState: String
    let scope: String?
    let source: Source?
}

private let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
private let decoder = JSONDecoder()

private func decode<T: Decodable>(_ type: T.Type, path: String) throws -> T {
    try decoder.decode(
        type,
        from: Data(contentsOf: root.appendingPathComponent(path))
    )
}

private func counts<S: Sequence>(_ values: S) -> [(String, Int)] where S.Element == String {
    Dictionary(grouping: values, by: { $0 })
        .map { ($0.key, $0.value.count) }
        .sorted { lhs, rhs in
            lhs.1 == rhs.1 ? lhs.0 < rhs.0 : lhs.1 > rhs.1
        }
}

private func table(_ heading: String, values: [(String, Int)]) -> String {
    var lines = ["## \(heading)", "", "| Value | Count |", "| --- | ---: |"]
    lines.append(contentsOf: values.map { "| \($0.0) | \($0.1) |" })
    return lines.joined(separator: "\n")
}

private func isValidCheckDate(_ value: String?) -> Bool {
    guard let value else { return false }
    let parts = value.split(separator: "-", omittingEmptySubsequences: false)
    guard
        parts.count == 3,
        parts[0].count == 4,
        parts[1].count == 2,
        parts[2].count == 2,
        let year = Int(parts[0]),
        let month = Int(parts[1]),
        let day = Int(parts[2])
    else {
        return false
    }
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    guard let date = calendar.date(from: DateComponents(year: year, month: month, day: day)) else {
        return false
    }
    let resolved = calendar.dateComponents([.year, .month, .day], from: date)
    return resolved.year == year && resolved.month == month && resolved.day == day
}

private let tr: [LocalizedDay] = try decode([LocalizedDay].self, path: "WhaDayNative/Data/tr.json")
private let en: [LocalizedDay] = try decode([LocalizedDay].self, path: "WhaDayNative/Data/en.json")
private let metadata: [Metadata] = try decode([Metadata].self, path: "WhaDayNative/Data/metadata.json")

private let trByID = Dictionary(uniqueKeysWithValues: tr.map { ($0.id, $0) })
private let enByID = Dictionary(uniqueKeysWithValues: en.map { ($0.id, $0) })
private let metadataByID = Dictionary(uniqueKeysWithValues: metadata.map { ($0.id, $0) })
private let allIDs = Set(tr.map(\.id)).union(en.map(\.id)).union(metadata.map(\.id))

private var structuralIssues: [String] = []
private var semanticSafetyIssues: [String] = []
if tr.count != trByID.count { structuralIssues.append("Turkish IDs are not unique") }
if en.count != enByID.count { structuralIssues.append("English IDs are not unique") }
if metadata.count != metadataByID.count { structuralIssues.append("Metadata IDs are not unique") }
if tr.count != 366 { structuralIssues.append("Turkish corpus has \(tr.count), expected 366") }
if en.count != 366 { structuralIssues.append("English corpus has \(en.count), expected 366") }
if metadata.count != 366 { structuralIssues.append("Metadata corpus has \(metadata.count), expected 366") }

for id in allIDs.sorted() {
    guard let trDay = trByID[id], let enDay = enByID[id], let record = metadataByID[id] else {
        structuralIssues.append("\(id) is missing from at least one corpus")
        continue
    }
    if trDay.month != enDay.month || trDay.day != enDay.day {
        structuralIssues.append("\(id) has mismatched localized dates")
    }
    if !(1...5).contains(record.shareability) {
        structuralIssues.append("\(id) has invalid shareability \(record.shareability)")
    }
    if record.symbol.isEmpty || record.symbol == "🔔" {
        structuralIssues.append("\(id) has an invalid public symbol")
    }
    if record.authority == "official" {
        guard let source = record.source else {
            structuralIssues.append("\(id) is official without a source")
            continue
        }
        if !source.url.hasPrefix("https://") || !isValidCheckDate(source.checkedAt) {
            structuralIssues.append("\(id) has an unverified official source")
        }
    }

    if record.sensitivity != "standard" && record.shareability > 2 {
        semanticSafetyIssues.append("\(id) is sensitive but has shareability \(record.shareability)")
    }

    let combinedTitle = "\(trDay.title) \(enDay.title)".lowercased()
    let sensitiveTitleSignals = [
        "abuse", "african descent", "aggression", "aids", "albinism", "blood donor", "breastfeeding",
        "cerebral palsy", "chagas", "chemical warfare", "child labour", "colonialism", "conjoined twins",
        "crimes against journalists", "disabilities", "disappearance", "drowning", "earthquake victims",
        "equal pay", "exploitation of the environment in war", "extremism", "genital mutilation", "hate speech",
        "holocaust", "impunity", "intersex", "islamophobia", "migrants", "nuclear tests", "nuclear weapons",
        "obstetric fistula", "palestinian people", "poverty", "refugee", "romani", "sex workers",
        "sexual violence", "slavery", "stuttering", "suicide", "tobacco", "transgender", "tsunami",
        "terrorism", "violence against", "widows", "afrika köken", "albinizm", "ayrımcılık", "boğulma",
        "çocuk işçiliği", "cinsel şiddet", "dul kadın", "engelliler", "eşit ücret", "filistin halkı",
        "göçmenler", "hiv", "istismar", "islamofobi", "kadın sünnet", "kan bağış", "kekemelik",
        "kimyasal savaş", "köle", "mülteci", "nefret söylemi", "nükleer deneme", "nükleer silah",
        "obstetrik fistül", "romanlar", "seks işçileri", "serebral palsi", "sömürgecilik", "soykırım",
        "tütün", "trans görünürlük", "tsunami", "şiddet", "terör", "yapışık ikiz", "yoksulluğun",
        "zorla kaybed"
    ]
    let isPositiveNonviolenceTitle = combinedTitle.contains("non-violence")
        || combinedTitle.contains("nonviolence")
        || combinedTitle.contains("şiddetsizlik")
    if record.sensitivity == "standard", !isPositiveNonviolenceTitle,
       sensitiveTitleSignals.contains(where: combinedTitle.contains) {
        semanticSafetyIssues.append("\(id) has a sensitive title but standard metadata")
    }

    let movingObservanceTitles = [
        "world maritime day", "dünya denizcilik günü",
        "international day of cooperatives", "uluslararası kooperatifler günü",
        "world day of remembrance for road traffic victims", "dünya trafik kazası kurbanlarını anma günü",
        "rare disease day", "nadir hastalıklar günü"
    ]
    if movingObservanceTitles.contains(where: combinedTitle.contains) {
        semanticSafetyIssues.append("\(id) stores a moving observance as a permanent date")
    }

    if record.reviewState == "curated" {
        let hasLegacyDescription = trDay.description.contains("Dünya çapında kutlanan ve anılan önemli bir gün")
            || enDay.description.localizedCaseInsensitiveContains("A globally celebrated and observed day")
        let hasLegacyHook = trDay.sharingHook == "Farkındalık yayarak bilgilendir"
            || enDay.sharingHook == "Raise awareness"
        if hasLegacyDescription || hasLegacyHook {
            semanticSafetyIssues.append("\(id) is curated but still contains legacy copy")
        }
    }
}

private let genericTR = tr.filter {
    $0.description.contains("Dünya çapında kutlanan ve anılan önemli bir gün")
}.count
private let genericEN = en.filter {
    $0.description.localizedCaseInsensitiveContains("A globally celebrated and observed day")
}.count
private let defaultHookTR = tr.filter { $0.sharingHook == "Farkındalık yayarak bilgilendir" }.count
private let defaultHookEN = en.filter { $0.sharingHook == "Raise awareness" }.count
private let verifiedSources = metadata.filter {
    guard let source = $0.source else { return false }
    return source.url.hasPrefix("https://") && isValidCheckDate(source.checkedAt)
}.count
private let unreviewed = metadata.filter { $0.reviewState != "curated" }

private let prioritized = unreviewed.sorted { lhs, rhs in
    if lhs.reviewState != rhs.reviewState {
        return lhs.reviewState == "needs-safety-review"
    }
    if lhs.shareability != rhs.shareability {
        return lhs.shareability > rhs.shareability
    }
    return lhs.id < rhs.id
}.prefix(40)

private var report: [String] = [
    "# WhaDay Content Audit",
    "",
    "Generated: \(ISO8601DateFormatter().string(from: Date()))",
    "",
    "This report is generated by `swift scripts/audit_content.swift --write`.",
    "It separates structural validity, source provenance and editorial readiness.",
    "",
    "## Readiness summary",
    "",
    "| Check | Result |",
    "| --- | ---: |",
    "| Turkish records | \(tr.count) |",
    "| English records | \(en.count) |",
    "| Metadata records | \(metadata.count) |",
    "| Structural issues | \(structuralIssues.count) |",
    "| Semantic safety issues | \(semanticSafetyIssues.count) |",
    "| Verified primary sources | \(verifiedSources) |",
    "| Turkish generic descriptions | \(genericTR) |",
    "| English generic descriptions | \(genericEN) |",
    "| Turkish default sharing hooks | \(defaultHookTR) |",
    "| English default sharing hooks | \(defaultHookEN) |",
    "| Unreviewed records | \(unreviewed.count) |",
    ""
]

if structuralIssues.isEmpty {
    report.append(contentsOf: ["## Structural issues", "", "None.", ""])
} else {
    report.append(contentsOf: ["## Structural issues", ""])
    report.append(contentsOf: structuralIssues.map { "- \($0)" })
    report.append("")
}

if semanticSafetyIssues.isEmpty {
    report.append(contentsOf: ["## Semantic safety issues", "", "None.", ""])
} else {
    report.append(contentsOf: ["## Semantic safety issues", ""])
    report.append(contentsOf: semanticSafetyIssues.map { "- \($0)" })
    report.append("")
}

report.append(table("Authority distribution", values: counts(metadata.map(\.authority))))
report.append("")
report.append(table("Review distribution", values: counts(metadata.map(\.reviewState))))
report.append("")
report.append(table("Sensitivity distribution", values: counts(metadata.map(\.sensitivity))))
report.append("")
report.append(table("Category distribution", values: counts(metadata.map(\.category))))
report.append(contentsOf: [
    "",
    "## Next editorial batch",
    "",
    "Safety-review items come first, then high-shareability items. This is a work queue, not an approval claim.",
    "",
    "| ID | TR title | EN title | Review | Score |",
    "| --- | --- | --- | --- | ---: |"
])
report.append(contentsOf: prioritized.compactMap { record in
    guard let trDay = trByID[record.id], let enDay = enByID[record.id] else { return nil }
    return "| \(record.id) | \(trDay.title) | \(enDay.title) | \(record.reviewState) | \(record.shareability) |"
})
report.append(contentsOf: [
    "",
    "## Release-candidate rule",
    "",
    "The strict audit passes only when structural and semantic safety issues are zero, every record is curated, and generic legacy description/hook counts are zero."
])

private let rendered = report.joined(separator: "\n") + "\n"
if CommandLine.arguments.contains("--write") {
    try rendered.write(
        to: root.appendingPathComponent("docs/CONTENT_AUDIT_LATEST.md"),
        atomically: true,
        encoding: .utf8
    )
}
print(rendered)

if CommandLine.arguments.contains("--strict") {
    let strictFailures = structuralIssues.count + semanticSafetyIssues.count + unreviewed.count + genericTR + genericEN + defaultHookTR + defaultHookEN
    if strictFailures > 0 {
        fputs("Strict audit failed with \(strictFailures) unresolved checks.\n", stderr)
        exit(1)
    }
}
