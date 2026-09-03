import XCTest
@testable import WhaDayNative

final class DayBetTests: XCTestCase {

    func testDayBetCreationAndResolution() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        var bet = DayBet(
            id: "bet-1",
            dayID: "06-15",
            title: "Kimin not ortalaması daha yüksek gelecek?",
            stake: "Kaybeden Kadıköy'de pizza ısmarlar 🍕",
            partyA: "Göktürk",
            partyB: "Can",
            targetMonth: 6,
            targetDay: 15
        )

        XCTAssertFalse(bet.isResolved)
        XCTAssertNil(bet.winner)
        XCTAssertNil(bet.loser())

        // Date before June 15 -> locked
        let june1 = calendar.date(from: DateComponents(year: 2026, month: 6, day: 1))!
        XCTAssertTrue(bet.isLocked(at: june1, calendar: calendar))

        // Date on June 15 -> unlocked
        let june15 = calendar.date(from: DateComponents(year: 2026, month: 6, day: 15))!
        XCTAssertFalse(bet.isLocked(at: june15, calendar: calendar))

        // Resolve bet
        bet.winner = "Göktürk"
        XCTAssertTrue(bet.isResolved)
        XCTAssertEqual(bet.winner, "Göktürk")
        XCTAssertEqual(bet.loser(), "Can")
    }

    @MainActor
    func testDayBetStoreOperations() {
        let testDefaults = UserDefaults(suiteName: "test.bet.\(UUID().uuidString)")!
        let store = DayBetStore(
            appGroupID: "test.group.bet.\(UUID().uuidString)",
            standardDefaults: testDefaults
        )

        XCTAssertTrue(store.bets(for: "06-15").isEmpty)

        let created = store.addBet(
            dayID: "06-15",
            title: "Derbi Bahsi",
            stake: "Forma",
            partyA: "Göktürk",
            partyB: "Ahmet",
            targetMonth: 6,
            targetDay: 15
        )

        XCTAssertEqual(store.bets(for: "06-15").count, 1)
        XCTAssertEqual(store.bets(for: "06-15").first?.title, "Derbi Bahsi")

        store.resolveBet(betID: created.id, dayID: "06-15", winner: "Göktürk")
        XCTAssertEqual(store.bets(for: "06-15").first?.winner, "Göktürk")

        store.deleteBet(id: created.id, dayID: "06-15")
        XCTAssertTrue(store.bets(for: "06-15").isEmpty)
    }

    @MainActor
    func testSoundtrackStoreOperations() {
        let testDefaults = UserDefaults(suiteName: "test.soundtrack.\(UUID().uuidString)")!
        let store = DaySoundtrackStore(
            appGroupID: "test.group.st.\(UUID().uuidString)",
            standardDefaults: testDefaults
        )

        XCTAssertNil(store.soundtrack(for: "09-05"))

        let st = store.setSoundtrack(
            dayID: "09-05",
            trackTitle: "One More Time",
            artistName: "Daft Punk",
            musicURL: "https://open.spotify.com/track/sample",
            addedBy: "Göktürk"
        )

        XCTAssertNotNil(store.soundtrack(for: "09-05"))
        XCTAssertEqual(store.soundtrack(for: "09-05")?.trackTitle, "One More Time")
        XCTAssertEqual(st.targetPlaybackURL()?.absoluteString, "https://open.spotify.com/track/sample")

        store.removeSoundtrack(for: "09-05")
        XCTAssertNil(store.soundtrack(for: "09-05"))
    }
}
