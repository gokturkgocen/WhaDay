import XCTest

@MainActor
final class WhaDayAccessibilityUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testTurkishCoreJourneyAtCurrentSystemTextSize() throws {
        try exerciseCoreJourney(language: "tr", locale: "tr_TR", prefix: "TR")
    }

    func testEnglishCoreJourneyAtCurrentSystemTextSize() throws {
        try exerciseCoreJourney(language: "en", locale: "en_US", prefix: "EN")
    }

    func testWhaDayPlusIsAvailableWithoutInterruptingTheCoreJourney() throws {
        let app = XCUIApplication()
        app.launchArguments = [
            "-AppleLanguages", "(tr)",
            "-AppleLocale", "tr_TR",
            "-hasCompletedFirstUseCoach", "YES"
        ]
        app.launch()

        XCTAssertTrue(app.buttons["home.settings"].waitForExistence(timeout: 5))
        app.buttons["home.settings"].tap()

        let plusEntry = app.buttons["settings.plus"]
        XCTAssertTrue(plusEntry.waitForExistence(timeout: 5))
        for _ in 0..<6 where !plusEntry.isHittable {
            app.swipeUp()
        }
        XCTAssertTrue(plusEntry.isHittable)
        plusEntry.tap()

        XCTAssertTrue(app.buttons["plus.close"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["plus.purchase"].exists)
        XCTAssertTrue(app.buttons["plus.restore"].exists)
        attachScreenshot(named: "TR-Plus-Paywall")
        app.buttons["plus.close"].tap()
    }

    private func exerciseCoreJourney(
        language: String,
        locale: String,
        prefix: String
    ) throws {
        let app = XCUIApplication()
        app.launchArguments = [
            "-AppleLanguages", "(\(language))",
            "-AppleLocale", locale,
            "-hasCompletedFirstUseCoach", "YES"
        ]
        app.launch()

        XCTAssertTrue(app.buttons["home.calendar"].waitForExistence(timeout: 5))
        attachScreenshot(named: "\(prefix)-Home-Top")

        let share = app.buttons["home.share"]
        for _ in 0..<10 where !share.isHittable {
            app.swipeUp()
        }
        XCTAssertTrue(share.isHittable, "Share action must remain reachable at the current text size.")
        attachScreenshot(named: "\(prefix)-Home-Share")

        share.tap()
        XCTAssertTrue(app.buttons["share.close"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["share.primary"].exists)
        attachScreenshot(named: "\(prefix)-Share-Studio")

        let storyFormat = app.buttons["share.format.story"]
        XCTAssertTrue(storyFormat.exists)
        storyFormat.tap()
        attachScreenshot(named: "\(prefix)-Share-Story")

        app.buttons["share.close"].tap()

        let calendar = app.buttons["home.calendar"]
        for _ in 0..<10 where !calendar.isHittable {
            app.swipeDown()
        }
        XCTAssertTrue(calendar.isHittable)
        calendar.tap()
        XCTAssertTrue(app.buttons["calendar.back"].waitForExistence(timeout: 5))
        attachScreenshot(named: "\(prefix)-Discovery")
    }

    private func attachScreenshot(named name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
