import XCTest

@MainActor
final class WhaDayPerformanceUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testColdLaunchPerformance() {
        let app = XCUIApplication()
        app.launchArguments = [
            "-AppleLanguages", "(tr)",
            "-AppleLocale", "tr_TR",
            "-hasCompletedFirstUseCoach", "YES"
        ]
        let options = XCTMeasureOptions()
        options.iterationCount = 3

        measure(
            metrics: [XCTApplicationLaunchMetric(waitUntilResponsive: true)],
            options: options
        ) {
            app.launch()
            app.terminate()
        }
    }

    func testCalendarScrollPerformance() {
        let app = XCUIApplication()
        app.launchArguments = [
            "-AppleLanguages", "(tr)",
            "-AppleLocale", "tr_TR",
            "-hasCompletedFirstUseCoach", "YES"
        ]
        app.launch()
        XCTAssertTrue(app.buttons["home.calendar"].waitForExistence(timeout: 5))
        app.buttons["home.calendar"].tap()
        XCTAssertTrue(app.buttons["calendar.action"].waitForExistence(timeout: 5))
        app.buttons["calendar.action"].tap()

        let options = XCTMeasureOptions()
        options.iterationCount = 3
        var scrollDown = true
        measure(metrics: [XCTOSSignpostMetric.scrollDecelerationMetric], options: options) {
            if scrollDown {
                app.swipeUp(velocity: .fast)
            } else {
                app.swipeDown(velocity: .fast)
            }
            scrollDown.toggle()
        }
    }
}
