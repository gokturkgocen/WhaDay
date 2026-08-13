import Foundation

enum DayProvenanceKind: Equatable {
    case official
    case cultural
    case editorial
}

struct DayProvenance: Equatable {
    let kind: DayProvenanceKind
    let label: String
    let explanation: String
    let sourceName: String?
    let sourceURL: URL?

    var isOfficial: Bool { kind == .official }

    static func forEvent(_ event: DayEvent) -> DayProvenance {
        if let source = officialSources[event.id] {
            return DayProvenance(
                kind: .official,
                label: localized("Doğrulanmış uluslararası gün", "Verified international observance"),
                explanation: localized(
                    "Bu tarih \(source.organization) takviminde yer alır. WhaDay’deki metin, paylaşım için hazırlanmış kısa bir editoryal özettir.",
                    "This date appears on the \(source.organization) calendar. WhaDay's copy is a short editorial summary written for sharing."
                ),
                sourceName: source.organization,
                sourceURL: source.url
            )
        }

        if isCultural(event) {
            return DayProvenance(
                kind: .cultural,
                label: localized("Kültürel takvim günü", "Cultural calendar day"),
                explanation: localized(
                    "Bu gün kültürel veya geleneksel takvimlerde karşılık bulur; her ülkede resmî bir statüsü olduğu anlamına gelmez.",
                    "This date appears in cultural or traditional calendars; that does not mean it has official status in every country."
                ),
                sourceName: nil,
                sourceURL: nil
            )
        }

        return DayProvenance(
            kind: .editorial,
            label: localized("Eğlenceli takvim bahanesi", "Playful calendar prompt"),
            explanation: localized(
                "Bu, WhaDay’in seçtiği eğlenceli bir takvim bahanesidir. Resmî veya evrensel bir gün olduğu iddia edilmez.",
                "This is a playful calendar prompt selected by WhaDay. It is not presented as an official or universal observance."
            ),
            sourceName: nil,
            sourceURL: nil
        )
    }

    private struct OfficialSource {
        let organization: String
        let url: URL
    }

    private static let unitedNations = OfficialSource(
        organization: "United Nations",
        url: URL(string: "https://www.un.org/en/observances/list-days-weeks")!
    )
    private static let unesco = OfficialSource(
        organization: "UNESCO",
        url: URL(string: "https://www.unesco.org/en/days/list")!
    )
    private static let worldHealthOrganization = OfficialSource(
        organization: "World Health Organization",
        url: URL(string: "https://www.who.int/campaigns")!
    )

    // Only dates checked against a primary institutional calendar belong here.
    // Everything else is deliberately described without an official-status claim.
    private static let officialSources: [String: OfficialSource] = {
        var result: [String: OfficialSource] = [:]

        [
            "01-04", "01-24", "01-27", "02-11", "02-17", "02-20", "03-20", "03-22",
            "04-02", "04-22", "05-20", "06-05", "06-08", "06-17", "06-20",
            "06-21", "06-23", "07-15", "08-09", "08-12", "08-19", "09-09",
            "09-12", "09-21", "10-11", "10-15", "10-16", "10-24", "11-18",
            "12-03", "12-10"
        ].forEach { result[$0] = unitedNations }

        ["01-14", "02-13", "02-21", "04-23", "05-03"].forEach {
            result[$0] = unesco
        }

        ["04-07", "06-14", "10-10", "12-01"].forEach {
            result[$0] = worldHealthOrganization
        }

        return result
    }()

    private static func isCultural(_ event: DayEvent) -> Bool {
        let title = event.title.lowercased()
        let terms = [
            "yılbaşı", "noel", "christmas", "epifani", "epiphany", "aziz", "saint",
            "bayram", "easter", "paskalya", "festivus", "halloween", "cadılar",
            "bağımsızlık", "independence", "ulusal gün", "national day", "zafer günü"
        ]
        return terms.contains(where: title.contains)
    }

    private static func localized(_ turkish: String, _ english: String) -> String {
        DayEventStore.language == "tr" ? turkish : english
    }
}
