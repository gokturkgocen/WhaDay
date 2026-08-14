import XCTest
import UserNotifications
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

                let attachment = XCTAttachment(image: image)
                attachment.name = "WhaDay-\(style.rawValue)-\(format.rawValue)-Preview"
                attachment.lifetime = .keepAlways
                add(attachment)
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

    @MainActor
    func testInstagramStoryURLRequiresAConfiguredSourceApplication() throws {
        XCTAssertNil(InstagramStorySharer.shareURL(sourceApplicationID: nil))
        XCTAssertNil(InstagramStorySharer.shareURL(sourceApplicationID: ""))
        XCTAssertNil(InstagramStorySharer.shareURL(sourceApplicationID: "$(UNEXPANDED_VALUE)"))

        let url = try XCTUnwrap(
            InstagramStorySharer.shareURL(sourceApplicationID: " 123456789 ")
        )
        XCTAssertEqual(
            url.absoluteString,
            "instagram-stories://share?source_application=123456789"
        )
    }

    func testSensitivePersonalizationNeverUsesCelebratoryPressure() throws {
        let event = try XCTUnwrap(DayEventStore.event(id: "01-27"))

        for language in ["tr", "en"] {
            let suggestions = SharePersonalization.suggestions(for: event, language: language)
            let combined = suggestions.compactMap(\.note).joined(separator: " ").lowercased()
            XCTAssertTrue(suggestions.contains { $0.id == "plain" })
            XCTAssertFalse(combined.contains("resmen senin günün"))
            XCTAssertFalse(combined.contains("basically your day"))
            XCTAssertFalse(combined.contains("bahane"))
            XCTAssertFalse(combined.contains("excuse"))
        }
    }

    func testShareLayoutReservesStorySafeZonesAndShrinksLongTitles() {
        XCTAssertGreaterThanOrEqual(
            ShareCardLayout.verticalSafeInset(format: .story) * 3,
            250
        )
        XCTAssertEqual(ShareCardLayout.verticalSafeInset(format: .message), 24)
        XCTAssertLessThan(
            ShareCardLayout.titleSize(characterCount: 140, format: .story),
            ShareCardLayout.titleSize(characterCount: 20, format: .story)
        )
        XCTAssertLessThan(
            ShareCardLayout.titleSize(characterCount: 140, format: .message),
            ShareCardLayout.titleSize(characterCount: 20, format: .message)
        )
    }

    @MainActor
    func testCompleteShareMatrixRendersWhenRequested() throws {
        guard ProcessInfo.processInfo.environment["WHADAY_FULL_SHARE_MATRIX"] == "1" else {
            throw XCTSkip("Set WHADAY_FULL_SHARE_MATRIX=1 for the 4,392-render release-candidate gate.")
        }

        var renderCount = 0
        for language in ["tr", "en"] {
            let url = try XCTUnwrap(Bundle.main.url(forResource: language, withExtension: "json"))
            let data = try Data(contentsOf: url)
            let events = try JSONDecoder().decode([DayEvent].self, from: data)
                .map { $0.attaching(DayMetadataStore.byID[$0.id]) }
            XCTAssertEqual(events.count, 366)

            for event in events {
                for style in ShareCardStyle.allCases {
                    for format in ShareCardFormat.allCases {
                        let rendered: UIImage? = autoreleasepool {
                            ShareCardRenderer.render(
                                event: event,
                                colors: ThemeColors.forEvent(event),
                                format: format,
                                style: style,
                                personalNote: SharePersonalization.suggestions(
                                    for: event,
                                    language: language
                                ).first?.note,
                                language: language
                            )
                        }
                        let image = try XCTUnwrap(
                            rendered,
                            "\(language)/\(event.id)/\(style.rawValue)/\(format.rawValue)"
                        )
                        XCTAssertEqual(image.cgImage?.width, Int(format.canvasSize.width * 3))
                        XCTAssertEqual(image.cgImage?.height, Int(format.canvasSize.height * 3))
                        renderCount += 1
                    }
                }
            }
        }

        XCTAssertEqual(renderCount, 4_392)
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

    func testCuratedSafetyCopyComesFromTheReviewedLocalizedCorpus() throws {
        let event = try XCTUnwrap(DayEventStore.event(month: 11, day: 15))
        let copy = EditorialContent.forEvent(event)

        XCTAssertEqual(copy.fact, event.description)
        XCTAssertEqual(copy.prompt, event.sharingHook)
        XCTAssertEqual(event.metadata?.reviewState, .curated)
        XCTAssertEqual(event.contentCategory, .civilSociety)
        XCTAssertEqual(event.sensitivity, .considerate)
        XCTAssertLessThanOrEqual(event.shareability, 2)
        XCTAssertTrue(copy.eyebrow.contains("NOT") || copy.eyebrow.contains("NOTE"))
    }

    func testEveryNonstandardDayUsesNoteLanguageAndBlocksPromotion() {
        for event in DayEventStore.days where event.sensitivity != .standard {
            let copy = EditorialContent.forEvent(event)
            XCTAssertTrue(
                copy.eyebrow.contains("NOT") || copy.eyebrow.contains("NOTE"),
                event.id
            )
            XCTAssertFalse(event.metadata?.canBePromotedForEngagement ?? true, event.id)
        }
    }

    func testNovemberSeventeenUsesReviewedWhaDayPromptInsteadOfOutdatedPrematurityDate() throws {
        let event = try XCTUnwrap(DayEventStore.event(month: 11, day: 17))
        let copy = EditorialContent.forEvent(event)

        XCTAssertEqual(event.title, "İlk Mesajı Atma Günü")
        XCTAssertEqual(event.authority, .editorial)
        XCTAssertEqual(event.sensitivity, .standard)
        XCTAssertEqual(event.shareability, 5)
        XCTAssertEqual(event.metadata?.reviewState, .curated)
        XCTAssertEqual(copy.fact, event.description)
        XCTAssertFalse(copy.fact.localizedCaseInsensitiveContains("premat"))
    }

    func testEveryCuratedRecordUsesTheReviewedLocalizedCorpus() throws {
        let metadata = DayMetadataStore.byID

        for language in ["tr", "en"] {
            let url = try XCTUnwrap(Bundle.main.url(forResource: language, withExtension: "json"))
            let events = try JSONDecoder().decode([DayEvent].self, from: Data(contentsOf: url))
                .map { $0.attaching(metadata[$0.id]) }

            for event in events where event.metadata?.reviewState == .curated {
                let copy = EditorialContent.forEvent(event, language: language)
                XCTAssertEqual(copy.fact, event.description, "\(language)/\(event.id)")
                XCTAssertEqual(copy.prompt, event.sharingHook, "\(language)/\(event.id)")
            }
        }
    }

    func testLeapDayIsAStableWhaDayPromptNotAMovingObservance() throws {
        let event = try XCTUnwrap(DayEventStore.event(month: 2, day: 29))

        XCTAssertEqual(event.title, "Fazladan Gün")
        XCTAssertEqual(event.authority, .editorial)
        XCTAssertEqual(event.metadata?.reviewState, .curated)
        XCTAssertFalse(event.description.localizedCaseInsensitiveContains("nadir hastalık"))
    }

    func testCalendarDataContainsLeapDayAndUniqueIdentifiers() {
        XCTAssertEqual(DayEventStore.days.count, 366)
        XCTAssertNotNil(DayEventStore.event(month: 2, day: 29))
        XCTAssertEqual(Set(DayEventStore.days.map(\.id)).count, DayEventStore.days.count)
    }

    func testWidgetCatalogLoadsBothLocalesBeforeTheAppWritesSharedState() throws {
        let metadataURL = try XCTUnwrap(Bundle.main.url(forResource: "metadata", withExtension: "json"))
        let metadata = try Data(contentsOf: metadataURL)

        for language in ["tr", "en"] {
            let localizedURL = try XCTUnwrap(Bundle.main.url(forResource: language, withExtension: "json"))
            let events = try WidgetDayCatalog.decode(
                localizedData: Data(contentsOf: localizedURL),
                metadataData: metadata
            )

            XCTAssertEqual(events.count, 366)
            XCTAssertNotNil(events.first { $0.id == "02-29" })
            XCTAssertEqual(events.first { $0.id == "01-27" }?.sensitivity, .remembrance)
            XCTAssertEqual(events.first { $0.id == "12-10" }?.symbol, "🕊️")
        }
    }

    func testWidgetCatalogFallsBackWhenMetadataIsCorrupt() throws {
        let localized = Data("""
        [{"id":"08-13","month":8,"day":13,"title":"Left-Handers Day","emoji":"✋","category":"fun"}]
        """.utf8)
        let events = try WidgetDayCatalog.decode(
            localizedData: localized,
            metadataData: Data("not-json".utf8)
        )

        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0].symbol, "✋")
        XCTAssertEqual(events[0].themeKey, "fun")
        XCTAssertEqual(events[0].sensitivity, .standard)
    }

    func testWidgetRefreshUsesTheNextLocalMidnightAcrossDST() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try XCTUnwrap(TimeZone(identifier: "America/New_York"))
        let date = try XCTUnwrap(calendar.date(from: DateComponents(
            year: 2026,
            month: 3,
            day: 8,
            hour: 12
        )))
        let refresh = WidgetDayCatalog.nextLocalMidnight(after: date, calendar: calendar)
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: refresh)

        XCTAssertEqual(components.year, 2026)
        XCTAssertEqual(components.month, 3)
        XCTAssertEqual(components.day, 9)
        XCTAssertEqual(components.hour, 0)
        XCTAssertEqual(components.minute, 0)
        XCTAssertGreaterThan(refresh, date)
    }

    func testWidgetLanguageSelectionUsesTurkishOnlyForTurkishLocales() {
        XCTAssertEqual(WidgetDayCatalog.languageCode(preferredLanguages: ["tr-TR"]), "tr")
        XCTAssertEqual(WidgetDayCatalog.languageCode(preferredLanguages: ["en-US"]), "en")
        XCTAssertEqual(WidgetDayCatalog.languageCode(preferredLanguages: ["de-DE"]), "en")
        XCTAssertEqual(WidgetDayCatalog.languageCode(preferredLanguages: []), "en")
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

    func testReminderPlanStaysWithinTheSystemBudgetAndHasNoDuplicates() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let now = ISO8601DateFormatter().date(from: "2026-01-01T08:00:00Z")!
        let configuration = ReminderConfiguration(
            isEnabled: true,
            hour: 9,
            minute: 15,
            savedIDs: []
        )
        let plan = ReminderPlanBuilder.make(
            configuration: configuration,
            now: now,
            calendar: calendar,
            events: DayEventStore.days,
            language: "tr",
            daysAhead: 500
        )

        XCTAssertEqual(plan.count, ReminderPlanBuilder.maximumScheduledDays)
        XCTAssertEqual(Set(plan.map(\.identifier)).count, plan.count)
        XCTAssertTrue(plan.allSatisfy { $0.fireDate > now })
        XCTAssertTrue(plan.allSatisfy { $0.identifier.hasPrefix(ReminderPlanBuilder.identifierPrefix) })
        XCTAssertTrue(plan.allSatisfy {
            let time = calendar.dateComponents([.hour, .minute], from: $0.fireDate)
            return time.hour == 9 && time.minute == 15
        })
    }

    func testReminderPlanSkipsPastTimeAndCarriesSavedContext() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let now = ISO8601DateFormatter().date(from: "2026-01-01T10:00:00Z")!
        let configuration = ReminderConfiguration(
            isEnabled: true,
            hour: 9,
            minute: 0,
            savedIDs: ["01-01", "01-02"]
        )
        let plan = ReminderPlanBuilder.make(
            configuration: configuration,
            now: now,
            calendar: calendar,
            events: DayEventStore.days,
            language: "tr"
        )

        XCTAssertEqual(plan.first?.eventID, "01-02")
        XCTAssertTrue(plan.first?.title.contains("Kaydettiğin") == true)
        XCTAssertEqual(Set(plan.map(\.identifier)).count, plan.count)
        XCTAssertTrue(plan.allSatisfy { $0.fireDate > now })
    }

    func testReminderAuthorizationAndDisabledPreferenceAreIndependent() {
        XCTAssertFalse(ReminderAuthorizationPolicy.permitsScheduling(.notDetermined))
        XCTAssertFalse(ReminderAuthorizationPolicy.permitsScheduling(.denied))
        XCTAssertTrue(ReminderAuthorizationPolicy.permitsScheduling(.authorized))
        XCTAssertTrue(ReminderAuthorizationPolicy.permitsScheduling(.provisional))

        let disabled = ReminderConfiguration(isEnabled: false, hour: 9, minute: 0, savedIDs: [])
        XCTAssertTrue(
            ReminderPlanBuilder.make(
                configuration: disabled,
                now: Date(),
                calendar: .current,
                events: DayEventStore.days,
                language: "en"
            ).isEmpty
        )
    }

    func testReminderPlanRebuildsFromANewNowAfterALongAbsence() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let returnDate = ISO8601DateFormatter().date(from: "2027-12-31T08:00:00Z")!
        let configuration = ReminderConfiguration(isEnabled: true, hour: 9, minute: 0, savedIDs: [])
        let plan = ReminderPlanBuilder.make(
            configuration: configuration,
            now: returnDate,
            calendar: calendar,
            events: DayEventStore.days,
            language: "en"
        )

        XCTAssertEqual(plan.first?.eventID, "12-31")
        XCTAssertEqual(plan.count, ReminderPlanBuilder.maximumScheduledDays)
        XCTAssertTrue(plan.contains { $0.identifier.contains("2028-01-01") })
    }

    @MainActor
    func testReminderPreferencePersistsSeparatelyFromAuthorization() {
        let suiteName = "ReminderPreferencesTests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let first = ReminderPreferences(defaults: defaults)
        XCTAssertFalse(first.isEnabled)
        XCTAssertEqual(first.hour, 9)
        first.setEnabled(true)
        first.setTime(hour: 18, minute: 45)

        let restored = ReminderPreferences(defaults: defaults)
        XCTAssertTrue(restored.isEnabled)
        XCTAssertEqual(restored.hour, 18)
        XCTAssertEqual(restored.minute, 45)
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
            "World Day of Remembrance for Road Traffic Victims", "Dünya Trafik Kazası Kurbanlarını Anma Günü",
            "Rare Disease Day", "Nadir Hastalıklar Günü"
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
