import XCTest
@testable import WhaDayNative

final class SharedSpaceTests: XCTestCase {

    func testSharedSpacePayloadRoundTrip() throws {
        let space = SharedSpace(
            id: "test-space-id",
            title: "Göktürk & Zeynep",
            emoji: "❤️",
            creatorName: "Göktürk"
        )

        let payload = try XCTUnwrap(space.toShareablePayload())
        XCTAssertFalse(payload.contains("+"))
        XCTAssertFalse(payload.contains("/"))
        XCTAssertFalse(payload.contains("="))

        let decoded = try XCTUnwrap(SharedSpace.from(shareablePayload: payload))
        XCTAssertEqual(decoded.id, "test-space-id")
        XCTAssertEqual(decoded.title, "Göktürk & Zeynep")
        XCTAssertEqual(decoded.emoji, "❤️")
        XCTAssertEqual(decoded.creatorName, "Göktürk")
    }

    func testSharedSpaceEventCountdown() {
        let event = SharedSpaceEvent(
            id: "ev-1",
            spaceID: "space-1",
            month: 9,
            day: 15,
            title: "Marmaris Tatili",
            description: "Tatil zamanı!",
            emoji: "🏖️",
            addedBy: "Göktürk"
        )

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        // Today is 3 Eylül 2026 -> 12 days left until 15 Eylül
        let sep3 = calendar.date(from: DateComponents(year: 2026, month: 9, day: 3))!
        XCTAssertEqual(event.daysRemaining(from: sep3, calendar: calendar), 12)

        // Today is 15 Eylül 2026 -> 0 days left (Today!)
        let sep15 = calendar.date(from: DateComponents(year: 2026, month: 9, day: 15))!
        XCTAssertEqual(event.daysRemaining(from: sep15, calendar: calendar), 0)
    }

    @MainActor
    func testSharedSpaceManagerLocalOperations() async throws {
        let testDefaults = UserDefaults(suiteName: "test.space.\(UUID().uuidString)")!
        let manager = SharedSpaceManager(
            containerIdentifier: "iCloud.com.gokturkgocen.whadayapp",
            appGroupID: "test.group.\(UUID().uuidString)",
            standardDefaults: testDefaults,
            enableCloudSync: false
        )

        XCTAssertTrue(manager.spaces.isEmpty)

        let space = try await manager.createSpace(
            title: "Bizim Tayfa",
            emoji: "🍕",
            creatorName: "Göktürk"
        )

        XCTAssertEqual(manager.spaces.count, 1)
        XCTAssertEqual(manager.spaces.first?.title, "Bizim Tayfa")

        let event = try await manager.addEvent(
            spaceID: space.id,
            month: 9,
            day: 20,
            title: "Pizza Gecesi",
            description: "Birlikte pizza yiyoruz",
            emoji: "🍕",
            author: "Göktürk"
        )

        XCTAssertEqual(manager.events(for: space.id).count, 1)

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let sep3 = calendar.date(from: DateComponents(year: 2026, month: 9, day: 3))!

        let upcoming = try XCTUnwrap(manager.nextUpcomingEvent(referenceDate: sep3))
        XCTAssertEqual(upcoming.event.title, "Pizza Gecesi")
        XCTAssertEqual(upcoming.daysRemaining, 17)

        let allDays = manager.allSharedDays()
        XCTAssertEqual(allDays.count, 1)
        XCTAssertEqual(allDays.first?.id, "09-20")
        XCTAssertEqual(allDays.first?.title, "Pizza Gecesi")
    }

    func testAppRouteSpaceInviteURLParsing() throws {
        let space = SharedSpace(
            id: "space-123",
            title: "Yaz Tatili",
            emoji: "🏖️",
            creatorName: "Ali"
        )

        let payload = try XCTUnwrap(space.toShareablePayload())

        let schemeURL = URL(string: "whaday://space?d=\(payload)")!
        let schemeRoute = try XCTUnwrap(AppRoute.parse(schemeURL))
        if case .incomingSpaceInvite(let parsed) = schemeRoute {
            XCTAssertEqual(parsed.id, "space-123")
            XCTAssertEqual(parsed.title, "Yaz Tatili")
            XCTAssertEqual(parsed.creatorName, "Ali")
        } else {
            XCTFail("Expected .incomingSpaceInvite route")
        }

        let webURL = URL(string: "https://gokturkgocen.github.io/WhaDay/s/?d=\(payload)")!
        let webRoute = try XCTUnwrap(AppRoute.parse(webURL))
        if case .incomingSpaceInvite(let parsed) = webRoute {
            XCTAssertEqual(parsed.id, "space-123")
            XCTAssertEqual(parsed.title, "Yaz Tatili")
        } else {
            XCTFail("Expected .incomingSpaceInvite route")
        }
    }
}
