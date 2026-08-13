import Foundation
import UserNotifications

/// Local notification scheduling for the morning ("today is X") and evening ("tomorrow is X")
/// reminders.
///
/// iOS caps pending local notifications at 64/app. This schedules a rolling ~30-day window
/// (2 notifications/day = 60 requests) and re-runs on every relevant foreground rather than
/// registering one request per day of content — a straight port of the RN version (which only
/// ever looked 7 days ahead) would silently start failing once the day-content gap is filled
/// toward covering the full year.
@MainActor
enum NotificationScheduler {
    private static let daysAhead = 30
    private static let center = UNUserNotificationCenter.current()

    static func requestPermission() async -> Bool {
        (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
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
                          title: morningTitle(event), body: event.description)
            }

            guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: date) else { continue }
            let tMonth = calendar.component(.month, from: tomorrow)
            let tDay = calendar.component(.day, from: tomorrow)

            if let event = DayEventStore.event(month: tMonth, day: tDay) {
                await add(tag: "evening", event: event, fireDay: date, hour: 21,
                          title: eveningTitle(event), body: eveningBody)
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
        DayEventStore.language == "tr"
            ? "\(event.emoji) Bugün \(event.title)!"
            : "\(event.emoji) Today is \(event.title)!"
    }

    private static func eveningTitle(_ event: DayEvent) -> String {
        DayEventStore.language == "tr"
            ? "\(event.emoji) Yarın \(event.title)!"
            : "\(event.emoji) Tomorrow is \(event.title)!"
    }

    private static var eveningBody: String {
        DayEventStore.language == "tr" ? "Yarın için hazırlan!" : "Don't forget about tomorrow!"
    }
}
