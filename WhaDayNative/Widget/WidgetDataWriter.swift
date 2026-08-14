import WidgetKit

enum WidgetDataWriter {
    static func save(event _: DayEvent?) {
        WidgetCenter.shared.reloadTimelines(ofKind: "WhaDayWidget")
    }
}
