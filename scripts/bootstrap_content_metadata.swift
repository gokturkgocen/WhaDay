#!/usr/bin/env swift

import Foundation

// One-time bootstrap for the locale-neutral content ledger. The generated
// review states are deliberately conservative: inference creates a review
// queue, never a claim that an entry has been independently researched.

private struct LocalizedEvent: Decodable {
    let id: String
    let title: String
    let emoji: String
}

private struct Source: Codable {
    let organization: String
    let url: String
    let checkedAt: String?
}

private struct Metadata: Codable {
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
private let inputURL = root.appendingPathComponent("WhaDayNative/Data/tr.json")
private let outputURL = root.appendingPathComponent("WhaDayNative/Data/metadata.json")

if FileManager.default.fileExists(atPath: outputURL.path), !CommandLine.arguments.contains("--force") {
    fputs("Refusing to overwrite the review ledger. Pass --force only before manual curation begins.\n", stderr)
    exit(2)
}

private let data = try Data(contentsOf: inputURL)
private let events = try JSONDecoder().decode([LocalizedEvent].self, from: data)

private let unitedNations = Source(
    organization: "United Nations",
    url: "https://www.un.org/en/observances/list-days-weeks",
    checkedAt: nil
)
private let unesco = Source(
    organization: "UNESCO",
    url: "https://www.unesco.org/en/days/list",
    checkedAt: nil
)
private let worldHealthOrganization = Source(
    organization: "World Health Organization",
    url: "https://www.who.int/campaigns",
    checkedAt: nil
)

private let unIDs: Set<String> = [
    "01-04", "01-24", "01-27", "02-11", "02-17", "02-20", "03-20", "03-22",
    "04-02", "04-22", "05-20", "06-05", "06-08", "06-17", "06-20", "06-21",
    "06-23", "07-15", "08-09", "08-12", "08-19", "09-09", "09-12", "09-21",
    "10-11", "10-15", "10-16", "10-24", "11-18", "12-03", "12-10"
]
private let unescoIDs: Set<String> = ["01-14", "02-13", "02-21", "04-23", "05-03"]
private let whoIDs: Set<String> = ["04-07", "06-14", "10-10", "12-01"]

private let remembranceIDs: Set<String> = [
    "01-27", "02-06", "02-12", "03-01", "03-05", "03-15", "03-25", "04-04",
    "04-29", "05-08", "06-04", "06-12", "06-15", "06-18", "06-19", "06-20",
    "08-02", "08-21", "08-22", "08-23", "08-29", "08-30", "09-09", "09-10",
    "09-11", "11-18", "11-25", "11-30", "12-02", "12-10"
]

private let curatedSymbols: [String: String] = [
    "01-02": "🚀", "01-03": "😴", "01-16": "🛋️", "01-18": "🍯", "01-20": "🐧",
    "01-21": "🫂", "01-29": "🧩", "02-05": "🍫", "02-09": "🍕", "02-14": "❤️",
    "02-29": "🦓", "03-06": "🍪", "03-09": "🎀", "03-14": "🥧", "03-16": "🐼",
    "03-20": "☀️", "04-01": "👀", "05-04": "🌌", "05-06": "🍽️", "05-20": "🐝",
    "05-21": "🫖", "07-02": "🛸", "07-05": "💻", "07-08": "🎮", "07-17": "😶",
    "07-30": "🫶", "07-31": "⚡️", "08-08": "🐈", "08-13": "✋", "08-26": "🐕",
    "09-19": "🏴‍☠️", "09-24": "🦍", "10-01": "☕️", "10-21": "⚡️", "10-25": "🍝",
    "10-31": "🎃", "11-13": "💛", "11-19": "🚽", "12-23": "✦", "12-29": "⏳",
    "12-30": "🥓", "12-31": "✨"
]

private func includes(_ title: String, _ terms: [String]) -> Bool {
    let tokens = Set(
        title.components(separatedBy: CharacterSet.letters.inverted)
            .filter { !$0.isEmpty }
    )
    return terms.contains { term in
        term.contains(" ") ? title.contains(term) : tokens.contains(term)
    }
}

private func source(for id: String) -> Source? {
    if unIDs.contains(id) { return unitedNations }
    if unescoIDs.contains(id) { return unesco }
    if whoIDs.contains(id) { return worldHealthOrganization }
    return nil
}

private func authority(for title: String, source: Source?) -> String {
    if source != nil { return "official" }

    let culturalTerms = [
        "yılbaşı", "noel", "epifani", "teofani", "ortodoks", "aziz", "azize", "yortusu",
        "paskalya", "ramazan", "bayram", "festivus", "cadılar bayramı", "meryem", "burns gecesi",
        "onikinci gece", "parinirvana", "songkran", "las posadas", "boxing day",
        "bağımsızlık", "ulusal gün", "devlet günü", "kurtuluş günü", "zafer günü", "bastille",
        "devrim günü", "kanada günü"
    ]
    return includes(title, culturalTerms) ? "cultural" : "editorial"
}

private func category(for title: String, id: String) -> String {
    if remembranceIDs.contains(id) { return "remembrance" }

    let groups: [(String, [String])] = [
        ("relationships", [
            "dostluk", "arkadaş", "aile", "ebeveyn", "kardeş", "çocuk günü", "sarıl", "öpme",
            "sevgili", "evlilik teklifi", "nezaket", "teşekkür", "gül günü", "komşu"
        ]),
        ("food-and-drink", [
            "pizza", "nutella", "oreo", "kahve", "çay", "süt", "turta", "makarna", "patates",
            "kek", "şeker", "bacon", "tahıl", "baklagil", "gıda", "ton balığı", "çikolata",
            "dondurma", "hamburger", "vegan", "aşçı", "waffle", "pankek", "meyve", "bira",
            "viski", "şarap", "kokteyl", "sandviç", "sushi", "ekmek", "yumurta", "peynir"
        ]),
        ("animals-and-nature", [
            "kedi", "köpek", "panda", "penguen", "kaplan", "aslan", "goril", "fil", "arı",
            "yaban hayat", "hayvan", "markhor", "kar leoparı", "sivrisinek", "kuş", "balina",
            "yunus", "ayı", "köpekbalığı", "orangutan", "gergedan", "tavşan", "maymun", "kurt",
            "dünya ana günü", "çevre", "okyanus", "orman", "göl", "sulak", "dünya su günü", "biyolojik",
            "ozon", "temiz hava", "sıfır atık", "geri dönüşüm", "dağ", "dağlar", "toprak"
        ]),
        ("culture-and-arts", [
            "kitap", "şiir", "okuma", "yazar", "müzik", "piyano", "caz", "radyo", "ses günü",
            "steelpan", "star wars", "geleceğe dönüş", "barbie", "televizyon", "animasyon", "tiyatro",
            "emoji", "dans", "fotoğraf", "müze", "sanat", "sinema", "çizgi roman", "çeviri",
            "dil günü", "anadil", "okuryazarlık", "braille", "işaret dilleri"
        ]),
        ("science-and-curiosity", [
            "bilim", "matematik", "pi günü", "uzay", "asteroid", "ufo", "tesla", "mühendis",
            "mucit", "mantık", "meteoroloji", "ışık günü", "internet", "programcı", "teknoloji",
            "istatistik", "ölçüm", "satranç", "havacılık"
        ]),
        ("sport-and-movement", [
            "spor", "futbol", "bisiklet", "basketbol", "yoga", "oyun günü", "fair play", "koşu",
            "kaykay", "yüzme", "jimnastik", "dans günü", "masa tenisi"
        ]),
        ("professions", [
            "öğretmen", "eczacı", "hakim", "tesisat", "denizci", "gönüllü", "barış gücü",
            "işletmeler", "hemşire", "doktor", "itfaiye", "veteriner", "pilot", "gazeteci",
            "mimar", "çiftçi", "aşçılar", "sekreter", "işçi", "posta"
        ]),
        ("health-and-awareness", [
            "sağlık", "hastalık", "prematüre", "parkinson", "diyabet", "epilepsi", "hemofili",
            "tüberküloz", "sıtma", "hepatit", "aids", "hiv", "zatürre", "osteoporoz", "menopoz",
            "hijyen", "ruh sağlığı", "otizm", "engelli", "kanser", "alzheimer", "kalp", "böbrek",
            "görme", "işitme", "kan bağışı", "aşı", "hasta", "sendromu", "obezite"
        ]),
        ("civil-society", [
            "eşit", "ayrımcılık", "hakları", "özgürlük", "görünürlük", "lgbtq", "lezbiyen",
            "interseks", "sosyal adalet", "hoşgörü", "kadınlar günü", "kız çocukları", "demokrasi",
            "barış", "mülteci", "insani yardım", "yoksulluk", "adalet", "insan hakları"
        ]),
        ("celebrations", [
            "yılbaşı", "noel", "epifani", "teofani", "ortodoks", "aziz", "azize", "yortusu",
            "paskalya", "ramazan", "bayram", "festivus", "cadılar", "bağımsızlık", "ulusal gün",
            "devlet günü", "kurtuluş günü", "zafer günü", "bastille", "devrim günü", "meryem",
            "burns gecesi", "onikinci gece", "parinirvana", "songkran", "las posadas", "boxing day"
        ])
    ]

    return groups.first(where: { includes(title, $0.1) })?.0 ?? "playful"
}

private func sensitivity(for title: String, id: String, category: String) -> String {
    if remembranceIDs.contains(id) { return "remembrance" }
    let considerateTerms = [
        "kanser", "hastalık", "sağlık", "diyabet", "epilepsi", "hemofili", "tüberküloz", "sıtma",
        "hepatit", "aids", "hiv", "zatürre", "parkinson", "alzheimer", "otizm", "engelli",
        "mülteci", "yoksulluk", "ayrımcılık", "şiddet", "istismar", "intihar", "terör", "kurban"
    ]
    if category == "health-and-awareness" || includes(title, considerateTerms) { return "considerate" }
    return "standard"
}

private func audience(for category: String, sensitivity: String) -> [String] {
    if sensitivity != "standard" { return ["careful-sharing"] }
    switch category {
    case "relationships": return ["friend", "family", "partner"]
    case "food-and-drink": return ["food-companion"]
    case "animals-and-nature": return ["animal-or-nature-lover"]
    case "culture-and-arts": return ["culture-lover"]
    case "science-and-curiosity": return ["curious-friend"]
    case "professions": return ["colleague", "professional"]
    case "sport-and-movement": return ["teammate"]
    case "celebrations": return ["observer", "community"]
    case "civil-society": return ["community"]
    default: return ["friend"]
    }
}

private func shareability(for category: String, sensitivity: String) -> Int {
    if sensitivity == "remembrance" { return 1 }
    if sensitivity == "considerate" { return 2 }
    switch category {
    case "relationships", "food-and-drink", "playful": return 5
    case "animals-and-nature", "culture-and-arts", "science-and-curiosity", "sport-and-movement": return 4
    default: return 3
    }
}

private func defaultSymbol(for category: String) -> String {
    switch category {
    case "relationships": return "🫶"
    case "food-and-drink": return "🍽️"
    case "animals-and-nature": return "🌿"
    case "culture-and-arts": return "🎨"
    case "science-and-curiosity": return "💡"
    case "health-and-awareness": return "☀️"
    case "professions": return "🤝"
    case "remembrance": return "🕊️"
    case "celebrations": return "✨"
    case "sport-and-movement": return "⚡️"
    case "civil-society": return "🤝"
    default: return "✦"
    }
}

private let metadata = events.map { event -> Metadata in
    let title = event.title.lowercased(with: Locale(identifier: "tr_TR"))
    let primarySource = source(for: event.id)
    let authority = authority(for: title, source: primarySource)
    let category = category(for: title, id: event.id)
    let sensitivity = sensitivity(for: title, id: event.id, category: category)
    let symbol = curatedSymbols[event.id]
        ?? (event.emoji == "🔔" ? defaultSymbol(for: category) : event.emoji)

    return Metadata(
        id: event.id,
        authority: authority,
        category: category,
        sensitivity: sensitivity,
        shareability: shareability(for: category, sensitivity: sensitivity),
        audience: audience(for: category, sensitivity: sensitivity),
        symbol: symbol,
        reviewState: sensitivity == "standard"
            ? (primarySource == nil ? "needs-editorial-review" : "source-linked")
            : "needs-safety-review",
        scope: authority == "official" ? "international" : authority == "cultural" ? "culture-specific" : "whaday-editorial",
        source: primarySource
    )
}

let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
let output = try encoder.encode(metadata)
try output.write(to: outputURL, options: .atomic)
print("Wrote \(metadata.count) conservative metadata records to \(outputURL.path)")
