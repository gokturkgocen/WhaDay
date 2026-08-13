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
        let colors = ThemeColors.forCategory(event.category)
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

    func testCalendarDataContainsLeapDayAndUniqueIdentifiers() {
        XCTAssertEqual(DayEventStore.days.count, 366)
        XCTAssertNotNil(DayEventStore.event(month: 2, day: 29))
        XCTAssertEqual(Set(DayEventStore.days.map(\.id)).count, DayEventStore.days.count)
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
