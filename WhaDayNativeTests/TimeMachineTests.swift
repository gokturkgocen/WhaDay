import XCTest
@testable import WhaDayNative

final class TimeMachineTests: XCTestCase {

    func testSharedSpaceWidgetDataStoreSaveAndLoad() {
        let sample = UpcomingSharedEventData(
            spaceID: "test-space",
            spaceTitle: "Bizim Günümüz",
            spaceEmoji: "❤️",
            eventTitle: "Marmaris Tatili",
            eventEmoji: "🏖️",
            month: 9,
            day: 15,
            daysRemaining: 12
        )

        SharedSpaceWidgetDataStore.save(sample)
        let loaded = SharedSpaceWidgetDataStore.load()

        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.spaceID, "test-space")
        XCTAssertEqual(loaded?.spaceTitle, "Bizim Günümüz")
        XCTAssertEqual(loaded?.eventTitle, "Marmaris Tatili")
        XCTAssertEqual(loaded?.daysRemaining, 12)
    }

    func testTimeMachineAnniversaryCopy() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let pastNote = CapsuleNote(
            id: "n1",
            capsuleID: "09-05",
            authorName: "Ahmet",
            content: "ronaldonun amk messi goat",
            targetMonth: 9,
            targetDay: 5,
            createdAt: calendar.date(from: DateComponents(year: 2025, month: 9, day: 1))!
        )

        let pastMem = PastMemory(
            id: "mem-1",
            dayID: "09-05",
            month: 9,
            day: 5,
            year: 2025,
            title: "Dünya Ronaldo Günü",
            emoji: "🐐",
            spaceTitle: "Bizim Tayfa",
            notes: [pastNote]
        )

        XCTAssertEqual(pastMem.dayID, "09-05")
        XCTAssertEqual(pastMem.notes.count, 1)
        XCTAssertEqual(pastMem.notes.first?.authorName, "Ahmet")
    }

    func testReminderPlanBuilderWithAnniversaryOverride() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let now = calendar.date(from: DateComponents(year: 2026, month: 9, day: 3, hour: 8, minute: 0))!
        let config = ReminderConfiguration(isEnabled: true, hour: 9, minute: 30, savedIDs: [])

        let sampleEvent = DayEvent(
            id: "09-05",
            month: 9,
            day: 5,
            title: "Orijinal Başlık",
            description: "Açıklama",
            emoji: "✨",
            category: "culture",
            sharingHook: "Hook",
            metadata: DayMetadata(
                id: "09-05",
                authority: .cultural,
                category: .cultureAndArts,
                sensitivity: .standard,
                shareability: 5,
                audience: [],
                symbol: "sparkles",
                reviewState: .curated,
                scope: nil,
                source: nil
            )
        )

        let plan = ReminderPlanBuilder.make(
            configuration: config,
            now: now,
            calendar: calendar,
            events: [sampleEvent],
            language: "tr",
            daysAhead: 5,
            anniversaryLookup: { date in
                let comps = calendar.dateComponents([.month, .day], from: date)
                if comps.month == 9 && comps.day == 5 {
                    return (title: "🕰️ Zaman Makinesi", body: "Tam 1 yıl önce bugün Ahmet bir not bırakmıştı.")
                }
                return nil
            }
        )

        let target = plan.first { $0.eventID == "09-05" }
        XCTAssertNotNil(target)
        XCTAssertEqual(target?.title, "🕰️ Zaman Makinesi")
        XCTAssertEqual(target?.body, "Tam 1 yıl önce bugün Ahmet bir not bırakmıştı.")
    }
}
