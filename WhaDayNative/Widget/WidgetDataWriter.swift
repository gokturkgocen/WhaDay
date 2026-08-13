import WidgetKit
import Foundation

enum WidgetDataWriter {
    private static let appGroupID = "group.com.gokturkgocen.whadayapp"

    static func save(event: DayEvent?, theme: BackgroundTheme, colors: ThemeColors) {
        guard let defaults = UserDefaults(suiteName: appGroupID) else { return }

        defaults.set(event?.emoji ?? "✨", forKey: "widgetEmoji")
        defaults.set(event?.title ?? "WhaDay", forKey: "widgetTitle")
        defaults.set(theme.rawValue, forKey: "widgetTheme")
        defaults.set(colors.gradient[0], forKey: "widgetGradientStart")
        defaults.set(colors.gradient[1], forKey: "widgetGradientMid")
        defaults.set(colors.gradient[2], forKey: "widgetGradientEnd")
        defaults.set(colors.blob1, forKey: "widgetBlob1")
        defaults.set(colors.blob2, forKey: "widgetBlob2")
        defaults.set(colors.blob3, forKey: "widgetBlob3")
        defaults.set(colors.accent, forKey: "widgetAccent")

        WidgetCenter.shared.reloadTimelines(ofKind: "WhaDayWidget")
    }
}
