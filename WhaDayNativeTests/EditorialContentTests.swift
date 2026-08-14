import XCTest
@testable import WhaDayNative

final class EditorialContentTests: XCTestCase {
    @MainActor
    func testShareCardsRenderAtChannelSpecificSizes() throws {
        let event = DayEvent(
            id: "08-13",
            month: 8,
            day: 13,
            title: "Dünya Solaklar Günü",
            description: "Placeholder",
            emoji: "🔔",
            category: "awareness",
            sharingHook: "Placeholder"
        )
        let colors = ThemeColors.forEvent(event)
        let story = try XCTUnwrap(ShareCardRenderer.render(event: event, colors: colors, format: .story))
        let message = try XCTUnwrap(ShareCardRenderer.render(event: event, colors: colors, format: .message))

        XCTAssertEqual(story.cgImage?.width, 1080)
        XCTAssertEqual(story.cgImage?.height, 1920)
        XCTAssertEqual(message.cgImage?.width, 1080)
        XCTAssertEqual(message.cgImage?.height, 1350)

        let storyAttachment = XCTAttachment(image: story)
        storyAttachment.name = "WhaDay-Story-Preview"
        storyAttachment.lifetime = .keepAlways
        add(storyAttachment)

        let messageAttachment = XCTAttachment(image: message)
        messageAttachment.name = "WhaDay-Message-Preview"
        messageAttachment.lifetime = .keepAlways
        add(messageAttachment)
    }

    @MainActor
    func testSensitiveStoryCardRendersAsANote() throws {
        let event = DayEvent(
            id: "12-10",
            month: 12,
            day: 10,
            title: "Dünya İnsan Hakları Günü",
            description: "Placeholder",
            emoji: "🕊️",
            category: "peace",
            sharingHook: "Placeholder"
        )
        let image = try XCTUnwrap(
            ShareCardRenderer.render(
                event: event,
                colors: ThemeColors.forEvent(event),
                format: .story
            )
        )

        XCTAssertEqual(image.cgImage?.width, 1080)
        XCTAssertEqual(image.cgImage?.height, 1920)

        let attachment = XCTAttachment(image: image)
        attachment.name = "WhaDay-Sensitive-Story-Preview"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    func testEveryShareStyleRendersForEveryChannel() throws {
        let event = DayEvent(
            id: "08-13",
            month: 8,
            day: 13,
            title: "Dünya Solaklar Günü",
            description: "Placeholder",
            emoji: "✋",
            category: "awareness",
            sharingHook: "Placeholder"
        )
        let colors = ThemeColors.forEvent(event)

        for style in ShareCardStyle.allCases {
            for format in ShareCardFormat.allCases {
                let image = try XCTUnwrap(
                    ShareCardRenderer.render(
                        event: event,
                        colors: colors,
                        format: format,
                        style: style,
                        personalNote: "Bunu görünce aklıma sen geldin."
                    )
                )
                XCTAssertEqual(image.cgImage?.width, Int(format.canvasSize.width * 3))
                XCTAssertEqual(image.cgImage?.height, Int(format.canvasSize.height * 3))
            }
        }
    }

    func testProvenanceDoesNotPresentPlayfulDaysAsOfficial() throws {
        let official = try XCTUnwrap(DayEventStore.event(month: 1, day: 24))
        let playful = try XCTUnwrap(DayEventStore.event(month: 1, day: 16))

        XCTAssertTrue(DayProvenance.forEvent(official).isOfficial)
        XCTAssertNotNil(DayProvenance.forEvent(official).sourceURL)
        XCTAssertFalse(DayProvenance.forEvent(playful).isOfficial)
        XCTAssertNil(DayProvenance.forEvent(playful).sourceURL)
    }

    func testSharePersonalizationAlwaysOffersAPlainCard() throws {
        let event = try XCTUnwrap(DayEventStore.event(month: 8, day: 13))
        let suggestions = SharePersonalization.suggestions(for: event)

        XCTAssertEqual(suggestions.count, 3)
        XCTAssertTrue(suggestions.contains(where: { $0.note == nil }))
        XCTAssertTrue(suggestions.contains(where: { $0.note != nil }))
    }

    func testWeeklyPicksCrossTheYearBoundaryWithoutRepeatingDays() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try XCTUnwrap(TimeZone(secondsFromGMT: 0))
        let start = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 12, day: 29)))

        let picks = WeeklyPicks.make(from: start, calendar: calendar)
        let allowedIDs = Set(["12-29", "12-30", "12-31", "01-01", "01-02", "01-03", "01-04"])

        XCTAssertEqual(picks.count, 3)
        XCTAssertEqual(Set(picks.map(\.id)).count, picks.count)
        XCTAssertTrue(picks.allSatisfy { allowedIDs.contains($0.id) })
        XCTAssertEqual(picks.map(\.dayOffset), picks.map(\.dayOffset).sorted())
    }

    func testWeeklyPicksNeverUseRemembranceCopyAsEngagementBait() {
        let remembrance = makeEvent(id: "08-13", title: "Savaş Kurbanlarını Anma Günü", category: "awareness")
        let candidates = [
            remembrance,
            makeEvent(id: "08-14", title: "Pizza Günü", category: "fun"),
            makeEvent(id: "08-15", title: "Dünya Kedi Günü", category: "social"),
            makeEvent(id: "08-16", title: "Bilim Günü", category: "science")
        ]
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let start = calendar.date(from: DateComponents(year: 2026, month: 8, day: 13))!

        let picks = WeeklyPicks.make(from: start, calendar: calendar, events: candidates)

        XCTAssertFalse(picks.contains(where: { $0.event.id == remembrance.id }))
    }

    func testWeeklyPicksPreferRelationalDaysOverCountryAndFaithDates() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try XCTUnwrap(TimeZone(secondsFromGMT: 0))
        let start = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 8, day: 13)))

        let picks = WeeklyPicks.make(from: start, calendar: calendar)

        XCTAssertEqual(picks.map(\.id), ["08-13", "08-16", "08-18"])
    }

    @MainActor
    func testSavedDaysRemainOnDeviceAndCanBeRemoved() throws {
        let suiteName = "WhaDayTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let event = try XCTUnwrap(DayEventStore.event(month: 8, day: 13))

        let firstStore = PersonalDayLibrary(defaults: defaults)
        firstStore.toggle(event)
        XCTAssertTrue(firstStore.isSaved(event))

        let restoredStore = PersonalDayLibrary(defaults: defaults)
        XCTAssertTrue(restoredStore.isSaved(event))

        restoredStore.toggle(event)
        XCTAssertFalse(restoredStore.isSaved(event))
    }

    func testCuratedLefthandersCopyIsPersonalAndSpecific() {
        let event = DayEvent(
            id: "08-13",
            month: 8,
            day: 13,
            title: "Dünya Solaklar Günü",
            description: "Placeholder",
            emoji: "🔔",
            category: "awareness",
            sharingHook: "Placeholder"
        )

        let content = EditorialContent.forEvent(event)

        XCTAssertFalse(content.fact.contains("Dünya çapında kutlanan"))
        XCTAssertEqual(EditorialSymbol.forEvent(event), "✋")
        XCTAssertFalse(content.prompt.isEmpty)
        XCTAssertFalse(content.shareMessage.isEmpty)
    }

    func testFallbackNeverReusesLegacyBoilerplate() {
        let event = DayEvent(
            id: "07-07",
            month: 7,
            day: 7,
            title: "Test Day",
            description: "A globally celebrated and observed day.",
            emoji: "🔔",
            category: "awareness",
            sharingHook: "Raise awareness"
        )

        let content = EditorialContent.forEvent(event)

        XCTAssertFalse(content.fact.contains("globally celebrated"))
        XCTAssertNotEqual(EditorialSymbol.forEvent(event), "🔔")
    }

    func testSemanticFallbacksAddressTheRightPerson() {
        let food = makeEvent(id: "05-30", title: "Uluslararası Patates Günü", category: "awareness")
        let animal = makeEvent(id: "07-29", title: "Uluslararası Kaplan Günü", category: "awareness")
        let books = makeEvent(id: "09-06", title: "Ulusal Kitap Okuma Günü", category: "awareness")

        let foodCopy = EditorialContent.forEvent(food)
        let animalCopy = EditorialContent.forEvent(animal)
        let bookCopy = EditorialContent.forEvent(books)

        XCTAssertNotEqual(foodCopy.prompt, animalCopy.prompt)
        XCTAssertNotEqual(animalCopy.prompt, bookCopy.prompt)
        XCTAssertTrue(
            foodCopy.prompt.localizedCaseInsensitiveContains("yiyeceğin") ||
            foodCopy.prompt.localizedCaseInsensitiveContains("bite")
        )
        XCTAssertTrue(
            animalCopy.prompt.localizedCaseInsensitiveContains("hayvan") ||
            animalCopy.prompt.localizedCaseInsensitiveContains("animal")
        )
        XCTAssertTrue(
            bookCopy.prompt.localizedCaseInsensitiveContains("kitap") ||
            bookCopy.prompt.localizedCaseInsensitiveContains("book")
        )
    }

    func testEveryDayHasShareableEditorialCopy() {
        let bannedPhrases = [
            "Dünya çapında kutlanan",
            "Farkındalık yayarak bilgilendir",
            "globally celebrated and observed"
        ]

        for event in DayEventStore.days {
            let copy = EditorialContent.forEvent(event)
            XCTAssertFalse(copy.fact.isEmpty, event.id)
            XCTAssertFalse(copy.prompt.isEmpty, event.id)
            XCTAssertFalse(copy.shareMessage.isEmpty, event.id)
            XCTAssertLessThanOrEqual(copy.fact.count, 190, event.id)
            for phrase in bannedPhrases {
                XCTAssertFalse(copy.fact.localizedCaseInsensitiveContains(phrase), "\(event.id): \(phrase)")
                XCTAssertFalse(copy.prompt.localizedCaseInsensitiveContains(phrase), "\(event.id): \(phrase)")
            }
        }
    }

    func testSensitiveDaysUseANoteInsteadOfAnExcuse() throws {
        let event = try XCTUnwrap(DayEventStore.event(month: 2, day: 6))
        let copy = EditorialContent.forEvent(event)

        XCTAssertTrue(copy.eyebrow.contains("NOT") || copy.eyebrow.contains("NOTE"))
        XCTAssertFalse(copy.prompt.localizedCaseInsensitiveContains("aklına gelen"))
        XCTAssertFalse(copy.prompt.localizedCaseInsensitiveContains("person you thought"))
    }

    func testCalendarDataContainsLeapDayAndUniqueIdentifiers() {
        XCTAssertEqual(DayEventStore.days.count, 366)
        XCTAssertNotNil(DayEventStore.event(month: 2, day: 29))
        XCTAssertEqual(Set(DayEventStore.days.map(\.id)).count, DayEventStore.days.count)
    }

    func testEveryLocalizedDayHasLocaleNeutralMetadata() {
        XCTAssertEqual(DayMetadataStore.entries.count, 366)
        XCTAssertEqual(Set(DayMetadataStore.entries.map(\.id)).count, 366)
        XCTAssertEqual(Set(DayMetadataStore.entries.map(\.id)), Set(DayEventStore.days.map(\.id)))

        for event in DayEventStore.days {
            let metadata = event.metadata
            XCTAssertNotNil(metadata, event.id)
            XCTAssertTrue(metadata?.hasValidShareability == true, event.id)
            XCTAssertFalse(metadata?.symbol.isEmpty ?? true, event.id)
            XCTAssertNotEqual(metadata?.symbol, "🔔", event.id)
        }
    }

    func testOfficialAuthorityAlwaysHasAPrimarySourceRecord() {
        for metadata in DayMetadataStore.entries where metadata.authority == .official {
            XCTAssertNotNil(metadata.source, metadata.id)
            XCTAssertFalse(metadata.source?.organization.isEmpty ?? true, metadata.id)
            XCTAssertEqual(metadata.source?.url.scheme, "https", metadata.id)
            XCTAssertTrue(metadata.source?.isVerified == true, metadata.id)
        }
    }

    func testSourceVerificationRequiresHTTPSAndARealCalendarDate() {
        XCTAssertTrue(
            DaySource(
                organization: "UNESCO",
                url: URL(string: "https://www.unesco.org/en/days/list")!,
                checkedAt: "2026-08-14"
            ).isVerified
        )
        XCTAssertFalse(
            DaySource(
                organization: "Example",
                url: URL(string: "http://example.com/day")!,
                checkedAt: "2026-08-14"
            ).isVerified
        )
        XCTAssertFalse(
            DaySource(
                organization: "Example",
                url: URL(string: "https://example.com/day")!,
                checkedAt: "2026-02-30"
            ).isVerified
        )
    }

    func testDayRoutesOpenOnlyRealCalendarDates() {
        XCTAssertEqual(
            AppRoute.parse(URL(string: "whaday://day/08-13")!),
            .day(id: "08-13")
        )
        XCTAssertEqual(AppRoute.parse(URL(string: "whaday://home")!), .home)
        XCTAssertEqual(AppRoute.parse(URL(string: "whaday://calendar")!), .discovery)
        XCTAssertEqual(AppRoute.parse(URL(string: "whaday://discover")!), .discovery)
        XCTAssertEqual(AppRoute.parse(URL(string: "whaday://settings")!), .settings)
        XCTAssertEqual(AppRoute.parse(URL(string: "whaday://share/08-13")!), .share(id: "08-13"))
        XCTAssertNil(AppRoute.parse(URL(string: "whaday://day/02-30")!))
        XCTAssertNil(AppRoute.parse(URL(string: "https://example.com/day/08-13")!))
        XCTAssertEqual(AppRoute.dayURL(id: "02-29")?.absoluteString, "whaday://day/02-29")
        XCTAssertEqual(AppRoute.shareURL(id: "02-29")?.absoluteString, "whaday://share/02-29")
    }

    func testNotificationRouteUsesTheExactDayIdentifier() {
        XCTAssertEqual(
            AppRoute.notificationRoute(userInfo: ["dayId": "12-31", "type": "morning"]),
            .day(id: "12-31")
        )
        XCTAssertNil(AppRoute.notificationRoute(userInfo: ["dayId": "13-01"]))
        XCTAssertNil(AppRoute.notificationRoute(userInfo: ["type": "morning"]))
    }

    func testDayResolutionUsesTheInjectedTimeZone() {
        let instant = ISO8601DateFormatter().date(from: "2026-08-13T21:30:00Z")!
        var istanbul = Calendar(identifier: .gregorian)
        istanbul.timeZone = TimeZone(identifier: "Europe/Istanbul")!
        var losAngeles = Calendar(identifier: .gregorian)
        losAngeles.timeZone = TimeZone(identifier: "America/Los_Angeles")!

        XCTAssertEqual(DayDateResolver.dayID(at: instant, calendar: istanbul), "08-14")
        XCTAssertEqual(DayDateResolver.dayID(at: instant, calendar: losAngeles), "08-13")
        XCTAssertEqual(DayEventStore.today(at: instant, calendar: istanbul)?.id, "08-14")
        XCTAssertEqual(DayEventStore.today(at: instant, calendar: losAngeles)?.id, "08-13")
    }

    func testNextBoundaryIsTheNextLocalMidnight() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Istanbul")!
        let instant = ISO8601DateFormatter().date(from: "2026-08-13T21:30:00Z")!
        let boundary = DayDateResolver.nextDayBoundary(after: instant, calendar: calendar)
        let components = boundary.map { calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: $0) }

        XCTAssertEqual(components?.year, 2026)
        XCTAssertEqual(components?.month, 8)
        XCTAssertEqual(components?.day, 15)
        XCTAssertEqual(components?.hour, 0)
        XCTAssertEqual(components?.minute, 0)
        XCTAssertEqual(components?.second, 1)
    }

    func testDiscoverySearchIsCaseAndDiacriticInsensitive() {
        let results = DayDiscoveryQuery.apply(
            to: DayEventStore.days,
            searchText: "SOLAKLAR",
            filter: .all,
            savedIDs: [],
            locale: Locale(identifier: "tr_TR")
        )
        XCTAssertTrue(results.contains { $0.id == "08-13" })
    }

    func testDiscoveryFiltersUseMetadataAndSavedState() {
        let events = DayEventStore.days
        let official = DayDiscoveryQuery.apply(
            to: events,
            searchText: "",
            filter: .official,
            savedIDs: [],
            locale: DayEventStore.dateLocale
        )
        XCTAssertFalse(official.isEmpty)
        XCTAssertTrue(official.allSatisfy { $0.authority == .official })

        let saved = DayDiscoveryQuery.apply(
            to: events,
            searchText: "",
            filter: .saved,
            savedIDs: ["08-13", "08-26"],
            locale: DayEventStore.dateLocale
        )
        XCTAssertEqual(Set(saved.map(\.id)), ["08-13", "08-26"])

        let sendable = DayDiscoveryQuery.apply(
            to: events,
            searchText: "",
            filter: .sendable,
            savedIDs: [],
            locale: DayEventStore.dateLocale
        )
        XCTAssertTrue(sendable.allSatisfy { $0.sensitivity == .standard && $0.shareability >= 4 })
    }

    func testWeeklyPicksAreStableAndSafeForEveryStartDateInALeapYear() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let start = calendar.date(from: DateComponents(year: 2024, month: 1, day: 1))!

        for offset in 0..<366 {
            let date = calendar.date(byAdding: .day, value: offset, to: start)!
            let first = WeeklyPicks.make(from: date, calendar: calendar)
            let second = WeeklyPicks.make(from: date, calendar: calendar)

            XCTAssertEqual(first, second, "Unstable picks at day offset \(offset)")
            XCTAssertEqual(Set(first.map(\.id)).count, first.count, "Repeated pick at day offset \(offset)")
            XCTAssertEqual(first.map(\.dayOffset), first.map(\.dayOffset).sorted(), "Unsorted picks at day offset \(offset)")
            XCTAssertTrue(first.allSatisfy { $0.dayOffset >= 0 && $0.dayOffset < 7 })
            XCTAssertTrue(first.allSatisfy { $0.event.sensitivity == .standard })
            XCTAssertTrue(first.allSatisfy { $0.event.metadata?.canBePromotedForEngagement == true })
        }
    }

    func testSensitiveMetadataCannotBePromotedAsEngagementContent() {
        for metadata in DayMetadataStore.entries where metadata.sensitivity != .standard {
            XCTAssertFalse(metadata.canBePromotedForEngagement, metadata.id)
            XCTAssertLessThanOrEqual(metadata.shareability, 2, metadata.id)
            XCTAssertTrue(
                metadata.reviewState == .needsSafetyReview || metadata.reviewState == .curated,
                metadata.id
            )
        }
    }

    func testNewTaxonomyHasNoSingleGenericMajorityBucket() {
        let counts = Dictionary(grouping: DayMetadataStore.entries, by: \.category).mapValues(\.count)
        XCTAssertLessThan(counts.values.max() ?? 0, DayMetadataStore.entries.count / 2)
        XCTAssertGreaterThanOrEqual(counts.keys.count, 10)
    }

    func testMovingObservancesAreNotStoredAsPermanentDates() {
        let titles = DayEventStore.days.map(\.title)
        let retiredMovingTitles = [
            "World Maritime Day", "Dünya Denizcilik Günü",
            "International Day of Cooperatives", "Uluslararası Kooperatifler Günü",
            "World Day of Remembrance for Road Traffic Victims", "Dünya Trafik Kazası Kurbanlarını Anma Günü"
        ]

        for title in retiredMovingTitles {
            XCTAssertFalse(titles.contains(title), title)
        }
    }

    private func makeEvent(id: String, title: String, category: String) -> DayEvent {
        let parts = id.split(separator: "-").compactMap { Int($0) }
        return DayEvent(
            id: id,
            month: parts.first ?? 1,
            day: parts.last ?? 1,
            title: title,
            description: "Placeholder",
            emoji: "🔔",
            category: category,
            sharingHook: "Placeholder"
        )
    }
}
