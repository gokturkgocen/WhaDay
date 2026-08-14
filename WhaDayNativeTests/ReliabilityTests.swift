import XCTest
@testable import WhaDayNative

final class ReliabilityTests: XCTestCase {
    @MainActor
    func testRouteCenterIgnoresInvalidURLsAndCannotConsumeANewerRequest() throws {
        let center = AppRouteCenter()
        center.open(.day(id: "08-13"))
        let first = try XCTUnwrap(center.request)

        center.open(URL(string: "https://example.com/not-whaday")!)
        XCTAssertEqual(center.request, first)

        center.open(.share(id: "12-31"))
        let second = try XCTUnwrap(center.request)
        XCTAssertNotEqual(second.id, first.id)
        XCTAssertEqual(second.route, .share(id: "12-31"))

        center.consume(first.id)
        XCTAssertEqual(center.request, second)
        center.consume(second.id)
        XCTAssertNil(center.request)
    }

    @MainActor
    func testDateContextRefreshUpdatesDayBoundaryTimeZoneAndLocaleTogether() throws {
        let instant = try XCTUnwrap(
            ISO8601DateFormatter().date(from: "2026-08-13T21:30:00Z")
        )
        var losAngeles = Calendar(identifier: .gregorian)
        losAngeles.timeZone = try XCTUnwrap(TimeZone(identifier: "America/Los_Angeles"))
        var istanbul = Calendar(identifier: .gregorian)
        istanbul.timeZone = try XCTUnwrap(TimeZone(identifier: "Europe/Istanbul"))
        let context = AppDateContext(
            now: instant,
            calendar: losAngeles,
            locale: Locale(identifier: "en_US")
        )

        XCTAssertEqual(context.dayID, "08-13")
        context.refresh(
            now: instant,
            calendar: istanbul,
            locale: Locale(identifier: "tr_TR")
        )

        XCTAssertEqual(context.dayID, "08-14")
        XCTAssertEqual(context.calendar.timeZone.identifier, "Europe/Istanbul")
        XCTAssertEqual(context.locale.identifier, "tr_TR")
        XCTAssertGreaterThan(try XCTUnwrap(context.nextDayBoundary), instant)
    }

    @MainActor
    func testSavedDayLibrarySelfHealsUnknownAndMalformedValues() throws {
        let suiteName = "PersonalDayLibraryReliabilityTests-\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        defaults.set(["08-13", "08-13", "13-99", "not-a-day"], forKey: "savedDayIDs")
        let filtered = PersonalDayLibrary(defaults: defaults)

        XCTAssertEqual(filtered.savedIDs, ["08-13"])
        XCTAssertEqual(defaults.stringArray(forKey: "savedDayIDs"), ["08-13"])

        defaults.set(["08-13", 42], forKey: "savedDayIDs")
        let recovered = PersonalDayLibrary(defaults: defaults)

        XCTAssertTrue(recovered.savedIDs.isEmpty)
        XCTAssertEqual(defaults.stringArray(forKey: "savedDayIDs"), [])
    }

    @MainActor
    func testReminderPreferencesClampAndRepairMalformedDefaults() throws {
        let suiteName = "ReminderPreferencesReliabilityTests-\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        defaults.set("enabled", forKey: "dailyReminderEnabled")
        defaults.set(99, forKey: "dailyReminderHour")
        defaults.set(-12, forKey: "dailyReminderMinute")

        let preferences = ReminderPreferences(defaults: defaults)

        XCTAssertFalse(preferences.isEnabled)
        XCTAssertEqual(preferences.hour, 23)
        XCTAssertEqual(preferences.minute, 0)
        XCTAssertFalse(defaults.bool(forKey: "dailyReminderEnabled"))
        XCTAssertEqual(defaults.integer(forKey: "dailyReminderHour"), 23)
        XCTAssertEqual(defaults.integer(forKey: "dailyReminderMinute"), 0)
    }

    func testReminderPlanClampsInvalidDirectConfiguration() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try XCTUnwrap(TimeZone(secondsFromGMT: 0))
        let now = try XCTUnwrap(ISO8601DateFormatter().date(from: "2026-01-01T08:00:00Z"))
        let configuration = ReminderConfiguration(
            isEnabled: true,
            hour: 99,
            minute: -12,
            savedIDs: []
        )

        let plan = ReminderPlanBuilder.make(
            configuration: configuration,
            now: now,
            calendar: calendar,
            events: DayEventStore.days,
            language: "en",
            daysAhead: 2
        )

        XCTAssertEqual(plan.count, 2)
        XCTAssertTrue(plan.allSatisfy {
            let time = calendar.dateComponents([.hour, .minute], from: $0.fireDate)
            return time.hour == 23 && time.minute == 0
        })
    }
}
