import XCTest
@testable import WhaDayNative

final class CapsuleNoteTests: XCTestCase {

    func testCapsuleNoteLockLogic() {
        let note = CapsuleNote(
            id: "note-1",
            capsuleID: "09-05",
            authorName: "Ahmet",
            content: "Ronaldo vs Messi goat tartışması!",
            targetMonth: 9,
            targetDay: 5
        )

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        // 3 Eylül 2026 (Before target) -> Locked
        let sep3 = calendar.date(from: DateComponents(year: 2026, month: 9, day: 3, hour: 12))!
        XCTAssertTrue(note.isLocked(at: sep3, calendar: calendar))

        // 4 Eylül 2026 23:59 (Eve of target) -> Locked
        let sep4Night = calendar.date(from: DateComponents(year: 2026, month: 9, day: 4, hour: 23, minute: 59))!
        XCTAssertTrue(note.isLocked(at: sep4Night, calendar: calendar))

        // 5 Eylül 2026 00:01 (Day of target) -> Unlocked!
        let sep5Morning = calendar.date(from: DateComponents(year: 2026, month: 9, day: 5, hour: 0, minute: 1))!
        XCTAssertFalse(note.isLocked(at: sep5Morning, calendar: calendar))

        // 6 Eylül 2026 (After target) -> Unlocked!
        let sep6 = calendar.date(from: DateComponents(year: 2026, month: 9, day: 6, hour: 10))!
        XCTAssertFalse(note.isLocked(at: sep6, calendar: calendar))
    }

    @MainActor
    func testCapsuleCloudManagerLocalCacheAndLockCounts() async throws {
        let testDefaults = UserDefaults(suiteName: "test.capsule.\(UUID().uuidString)")!
        let manager = CapsuleCloudManager(
            containerIdentifier: "iCloud.com.gokturkgocen.whadayapp",
            cacheDefaults: testDefaults,
            enableCloudSync: false
        )

        let capsuleID = "test-capsule-09-05"
        XCTAssertEqual(manager.notes(for: capsuleID).count, 0)

        try await manager.submitNote(
            capsuleID: capsuleID,
            authorName: "Mehmet",
            content: "Gizli mesaj!",
            targetMonth: 9,
            targetDay: 5
        )

        XCTAssertEqual(manager.notes(for: capsuleID).count, 1)

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let beforeDate = calendar.date(from: DateComponents(year: 2026, month: 9, day: 3))!
        let afterDate = calendar.date(from: DateComponents(year: 2026, month: 9, day: 5))!

        XCTAssertEqual(manager.lockedCount(for: capsuleID, referenceDate: beforeDate), 1)
        XCTAssertEqual(manager.unlockedNotes(for: capsuleID, referenceDate: beforeDate).count, 0)

        XCTAssertEqual(manager.lockedCount(for: capsuleID, referenceDate: afterDate), 0)
        XCTAssertEqual(manager.unlockedNotes(for: capsuleID, referenceDate: afterDate).count, 1)
        XCTAssertEqual(manager.unlockedNotes(for: capsuleID, referenceDate: afterDate).first?.content, "Gizli mesaj!")
    }
}
