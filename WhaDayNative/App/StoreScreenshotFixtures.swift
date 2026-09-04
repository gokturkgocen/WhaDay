import Foundation

/// Deterministic, process-local content used only by UI tests and App Store captures.
/// The flag is never passed in production, so customer data and CloudKit stay untouched.
enum StoreScreenshotFixtures {
    static let enabled = ProcessInfo.processInfo.arguments.contains("-seedStoreDayClub")

    static var dayID: String? {
        guard enabled else { return nil }
        let arguments = ProcessInfo.processInfo.arguments
        guard let flag = arguments.firstIndex(of: "-storeScreenshotDay"),
              arguments.indices.contains(flag + 1) else {
            return "09-18"
        }
        return arguments[flag + 1]
    }

    static var soundtrack: DaySoundtrack? {
        guard let dayID else { return nil }
        return DaySoundtrack(
            id: "store-screenshot-soundtrack",
            dayID: dayID,
            trackTitle: "Bir Derdim Var",
            artistName: "mor ve ötesi",
            musicURL: nil,
            addedBy: "Ekin",
            createdAt: Date(timeIntervalSince1970: 1_757_966_400)
        )
    }

    static var bet: DayBet? {
        guard let dayID else { return nil }
        return DayBet(
            id: "store-screenshot-bet",
            dayID: dayID,
            title: "Bu yolculukta kim daha az uyuyacak?",
            stake: "Kaybeden ilk kahveyi ısmarlar",
            partyA: "Ekin",
            partyB: "Partner",
            targetMonth: 9,
            targetDay: 18,
            winner: "Ekin",
            createdAt: Date(timeIntervalSince1970: 1_757_966_400)
        )
    }

    static var capsuleNotes: [CapsuleNote] {
        guard let dayID else { return [] }
        return [
            CapsuleNote(
                id: "store-screenshot-note-1",
                capsuleID: dayID,
                authorName: "Ekin",
                content: "Bu yolculuğun en güzel anını seneye yeniden hatırlayalım.",
                targetMonth: 9,
                targetDay: 18,
                createdAt: Date(timeIntervalSince1970: 1_757_966_400)
            ),
            CapsuleNote(
                id: "store-screenshot-note-2",
                capsuleID: dayID,
                authorName: "Partner",
                content: "Açıldığında ilk fotoğrafımıza birlikte bakalım.",
                targetMonth: 9,
                targetDay: 18,
                createdAt: Date(timeIntervalSince1970: 1_757_970_000)
            )
        ]
    }
}
