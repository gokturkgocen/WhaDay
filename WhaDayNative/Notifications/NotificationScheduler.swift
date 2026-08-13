import Foundation
import UserNotifications

/// One calm, social morning reminder per day.
///
/// iOS caps pending local notifications at 64/app. This schedules a rolling ~60-day window
/// and re-runs on every relevant foreground rather than
/// registering one request per day of content — a straight port of the RN version (which only
/// ever looked 7 days ahead) would silently start failing once the day-content gap is filled
/// toward covering the full year.
@MainActor
enum NotificationScheduler {
    private static let daysAhead = 60
    private static let center = UNUserNotificationCenter.current()

    static func requestPermission() async -> Bool {
        (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    static func scheduleIfAuthorized() async {
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else { return }
        await scheduleAll()
    }

    static func authorizationStatus() async -> UNAuthorizationStatus {
        await center.notificationSettings().authorizationStatus
    }

    static func scheduleAll() async {
        center.removeAllPendingNotificationRequests()

        let calendar = Calendar.current
        let now = Date()

        for offset in 0..<daysAhead {
            guard let date = calendar.date(byAdding: .day, value: offset, to: now) else { continue }
            let month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)

            if let event = DayEventStore.event(month: month, day: day) {
                await add(tag: "morning", event: event, fireDay: date, hour: 9,
                          title: morningTitle(event), body: morningBody(event))
            }
        }
    }

    private static func add(tag: String, event: DayEvent, fireDay: Date, hour: Int, title: String, body: String) async {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: fireDay)
        components.hour = hour
        components.minute = 0

        guard let fireDate = Calendar.current.date(from: components), fireDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.userInfo = ["dayId": event.id, "type": tag]

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let yyyy = components.year.map(String.init) ?? "0"
        let mm = String(format: "%02d", components.month ?? 0)
        let dd = String(format: "%02d", components.day ?? 0)
        let identifier = "\(tag)-\(event.id)-\(yyyy)-\(mm)-\(dd)"

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        try? await center.add(request)
    }

    private static func morningTitle(_ event: DayEvent) -> String {
        let symbol = EditorialSymbol.forEvent(event)
        let editorial = EditorialContent.forEvent(event)
        if editorial.tone == .remembrance {
            return DayEventStore.language == "tr"
                ? "\(symbol) Bugünün notu"
                : "\(symbol) Today's note"
        }
        return DayEventStore.language == "tr"
            ? "\(symbol) Bugün birine yazmak için bahanen var"
            : "\(symbol) You have a reason to text someone today"
    }

    private static func morningBody(_ event: DayEvent) -> String {
        let editorial = EditorialContent.forEvent(event)
        if editorial.tone == .remembrance {
            return "\(event.title). \(editorial.fact)"
        }
        return "\(event.title) · \(editorial.prompt)"
    }
}
