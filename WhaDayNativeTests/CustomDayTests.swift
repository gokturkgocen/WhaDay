import XCTest
@testable import WhaDayNative

final class CustomDayTests: XCTestCase {

    func testCustomDayPayloadRoundTrip() throws {
        let original = CustomDayRecord(
            id: "08-23",
            month: 8,
            day: 23,
            title: "Benim Doğum Günüm",
            description: "Bugün pasta kesme ve sevdiklerimle kutlama günü!",
            emoji: "🎂",
            authorName: "Göktürk",
            createdAt: Date(),
            isImported: false
        )

        let payload = try XCTUnwrap(original.toShareablePayload())
        XCTAssertFalse(payload.contains("+"))
        XCTAssertFalse(payload.contains("/"))
        XCTAssertFalse(payload.contains("="))

        let decoded = try XCTUnwrap(CustomDayRecord.from(shareablePayload: payload))
        XCTAssertEqual(decoded.id, "08-23")
        XCTAssertEqual(decoded.month, 8)
        XCTAssertEqual(decoded.day, 23)
        XCTAssertEqual(decoded.title, "Benim Doğum Günüm")
        XCTAssertEqual(decoded.description, "Bugün pasta kesme ve sevdiklerimle kutlama günü!")
        XCTAssertEqual(decoded.emoji, "🎂")
        XCTAssertEqual(decoded.authorName, "Göktürk")
        XCTAssertTrue(decoded.isImported)

        let event = decoded.toDayEvent()
        XCTAssertEqual(event.id, "08-23")
        XCTAssertEqual(event.title, "Benim Doğum Günüm")
        XCTAssertEqual(event.emoji, "🎂")
    }

    @MainActor
    func testCustomDayStorePersistenceAndEffectiveEvent() throws {
        let testDefaults = UserDefaults(suiteName: "test.custom.days.\(UUID().uuidString)")!
        let store = CustomDayStore(standardDefaults: testDefaults, appGroupID: "test.group.\(UUID().uuidString)")

        let dayID = "08-23"
        XCTAssertFalse(store.isCustom(dayID: dayID))

        let record = CustomDayRecord(
            id: dayID,
            month: 8,
            day: 23,
            title: "Özel Kutlama",
            description: "Bugün harika bir gün.",
            emoji: "🎉",
            authorName: "Ali"
        )

        store.save(record)
        XCTAssertTrue(store.isCustom(dayID: dayID))

        let effective = try XCTUnwrap(store.effectiveEvent(for: dayID))
        XCTAssertEqual(effective.title, "Özel Kutlama")
        XCTAssertEqual(effective.emoji, "🎉")

        let allDays = store.effectiveDays()
        let matchingInAll = try XCTUnwrap(allDays.first { $0.id == dayID })
        XCTAssertEqual(matchingInAll.title, "Özel Kutlama")

        store.remove(for: dayID)
        XCTAssertFalse(store.isCustom(dayID: dayID))

        let stockEvent = store.effectiveEvent(for: dayID)
        XCTAssertNotEqual(stockEvent?.title, "Özel Kutlama")
    }

    func testAppRouteParsesCustomDaySchemeAndWebURL() throws {
        let record = CustomDayRecord(
            id: "08-23",
            month: 8,
            day: 23,
            title: "Doğum Günü",
            description: "Kutlama vakti!",
            emoji: "🎂",
            authorName: "Göktürk"
        )

        let payload = try XCTUnwrap(record.toShareablePayload())

        let schemeURL = URL(string: "whaday://custom?d=\(payload)")!
        let schemeRoute = try XCTUnwrap(AppRoute.parse(schemeURL))
        if case .incomingCustomDay(let parsed) = schemeRoute {
            XCTAssertEqual(parsed.id, "08-23")
            XCTAssertEqual(parsed.title, "Doğum Günü")
            XCTAssertEqual(parsed.authorName, "Göktürk")
        } else {
            XCTFail("Expected .incomingCustomDay route")
        }

        let webURL = URL(string: "https://gokturkgocen.github.io/WhaDay/c/?d=\(payload)")!
        let webRoute = try XCTUnwrap(AppRoute.parse(webURL))
        if case .incomingCustomDay(let parsed) = webRoute {
            XCTAssertEqual(parsed.id, "08-23")
            XCTAssertEqual(parsed.title, "Doğum Günü")
        } else {
            XCTFail("Expected .incomingCustomDay route")
        }
    }
}
