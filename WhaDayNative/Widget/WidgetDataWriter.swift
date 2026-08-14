import WidgetKit
import Foundation

enum WidgetDataWriter {
    private static let appGroupID = "group.com.gokturkgocen.whadayapp"

    static func save(event: DayEvent?) {
        guard let defaults = UserDefaults(suiteName: appGroupID) else { return }

        let currentEvent = DayEventStore.today() ?? event
        let currentColors = ThemeColors.forEvent(currentEvent)

        defaults.set(currentEvent.map(EditorialSymbol.forEvent) ?? "✦", forKey: "widgetEmoji")
        defaults.set(currentEvent?.title ?? "WhaDay", forKey: "widgetTitle")
        defaults.set(DayEventStore.language, forKey: "widgetLanguage")
        if let data = try? JSONEncoder().encode(DayEventStore.days) {
            defaults.set(data, forKey: "widgetDays")
        }
        defaults.set(currentColors.paper, forKey: "widgetPaper")
        defaults.set(currentColors.ink, forKey: "widgetInk")
        defaults.set(currentColors.secondary, forKey: "widgetSecondary")
        defaults.set(currentColors.accent, forKey: "widgetAccent")

        WidgetCenter.shared.reloadTimelines(ofKind: "WhaDayWidget")
    }
}
