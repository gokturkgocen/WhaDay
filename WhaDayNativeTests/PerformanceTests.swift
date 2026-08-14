import XCTest
@testable import WhaDayNative

final class PerformanceTests: XCTestCase {
    func testLocalizedCatalogDecodePerformance() throws {
        let url = try XCTUnwrap(Bundle.main.url(forResource: "tr", withExtension: "json"))
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let options = XCTMeasureOptions()
        options.iterationCount = 5

        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()], options: options) {
            do {
                let events = try decoder.decode([DayEvent].self, from: data)
                XCTAssertEqual(events.count, 366)
            } catch {
                XCTFail("Catalog decode failed: \(error)")
            }
        }
    }

    func testDiscoveryQueryPerformance() {
        let options = XCTMeasureOptions()
        options.iterationCount = 5
        let queries = ["dünya", "gün", "kedi", "bilim", "arkadaş", "kahve"]

        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()], options: options) {
            var resultCount = 0
            for _ in 0..<100 {
                for query in queries {
                    resultCount += DayDiscoveryQuery.apply(
                        to: DayEventStore.days,
                        searchText: query,
                        filter: .all,
                        savedIDs: [],
                        locale: Locale(identifier: "tr_TR")
                    ).count
                }
            }
            XCTAssertGreaterThan(resultCount, 0)
        }
    }

    @MainActor
    func testMessageShareRenderPerformance() throws {
        let event = try XCTUnwrap(DayEventStore.event(id: "08-13"))
        let colors = ThemeColors.forEvent(event)
        let options = XCTMeasureOptions()
        options.iterationCount = 5

        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()], options: options) {
            autoreleasepool {
                XCTAssertNotNil(
                    ShareCardRenderer.render(
                        event: event,
                        colors: colors,
                        format: .message,
                        style: .editorial,
                        personalNote: "Bunu görünce aklıma sen geldin."
                    )
                )
            }
        }
    }
}
