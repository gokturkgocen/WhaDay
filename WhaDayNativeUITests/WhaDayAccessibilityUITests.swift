import XCTest

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
