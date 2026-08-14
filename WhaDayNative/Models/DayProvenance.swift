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
        switch event.authority {
        case .official:
            guard let source = event.metadata?.source else {
                return DayProvenance(
                    kind: .editorial,
                    label: localized("Kaynağı inceleniyor", "Source under review"),
                    explanation: localized(
                        "Bu gün için resmî statü gösterilmiyor; birincil kaynak incelemesi tamamlanmayı bekliyor.",
                        "Official status is not shown for this day while its primary-source review is incomplete."
                    ),
                    sourceName: nil,
                    sourceURL: nil
                )
            }
            let isVerified = source.isVerified
            return DayProvenance(
                kind: .official,
                label: isVerified
                    ? localized("Doğrulanmış uluslararası gün", "Verified international observance")
                    : localized("Kurumsal takvim kaydı", "Institutional calendar entry"),
                explanation: isVerified
                    ? localized(
                        "Bu tarih \(source.organization) takviminde doğrulandı. WhaDay’deki metin, paylaşım için hazırlanmış kısa bir editoryal özettir.",
                        "This date was verified on the \(source.organization) calendar. WhaDay's copy is a short editorial summary written for sharing."
                    )
                    : localized(
                        "Bu tarih için \(source.organization) kaynağı bağlıdır; ayrıntılı editoryal inceleme henüz tamamlanmamıştır.",
                        "A \(source.organization) source is linked for this date; its detailed editorial review is not complete yet."
                    ),
                sourceName: source.organization,
                sourceURL: source.url
            )
        case .cultural:
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
        case .editorial:
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
    }

    private static func localized(_ turkish: String, _ english: String) -> String {
        DayEventStore.language == "tr" ? turkish : english
    }
}
