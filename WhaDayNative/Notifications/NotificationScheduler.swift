import Foundation
import UserNotifications

struct PlannedReminder: Equatable {
    let identifier: String
    let eventID: String
    let fireDate: Date
    let title: String
    let body: String
}

enum ReminderAuthorizationPolicy {
    static func permitsScheduling(_ status: UNAuthorizationStatus) -> Bool {
        switch status {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined, .denied:
            return false
        @unknown default:
            return false
        }
    }
}

enum ReminderPlanBuilder {
    static let maximumScheduledDays = 60
    static let identifierPrefix = "whaday-reminder-"

    static func make(
        configuration: ReminderConfiguration,
        now: Date,
        calendar: Calendar,
        events: [DayEvent],
        language: String,
        daysAhead: Int = maximumScheduledDays
    ) -> [PlannedReminder] {
        guard configuration.isEnabled else { return [] }
        let eventByID = Dictionary(uniqueKeysWithValues: events.map { ($0.id, $0) })

        return (0..<min(max(daysAhead, 0), maximumScheduledDays)).compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: offset, to: now) else { return nil }
            var components = calendar.dateComponents([.year, .month, .day], from: day)
            components.hour = configuration.hour
            components.minute = configuration.minute
            components.second = 0

            guard
                let fireDate = calendar.date(from: components),
                fireDate > now
            else {
                return nil
            }

            let eventID = DayDateResolver.dayID(at: day, calendar: calendar)
            guard let event = eventByID[eventID] else { return nil }
            let copy = copy(
                for: event,
                isSaved: configuration.savedIDs.contains(event.id),
                language: language
            )
            let yyyy = String(format: "%04d", components.year ?? 0)
            let mm = String(format: "%02d", components.month ?? 0)
            let dd = String(format: "%02d", components.day ?? 0)
            let identifier = "\(identifierPrefix)\(yyyy)-\(mm)-\(dd)-\(event.id)"

            return PlannedReminder(
                identifier: identifier,
                eventID: event.id,
                fireDate: fireDate,
                title: copy.title,
                body: copy.body
            )
        }
    }

    private static func copy(
        for event: DayEvent,
        isSaved: Bool,
        language: String
    ) -> (title: String, body: String) {
        let isTurkish = language == "tr"
        let symbol = EditorialSymbol.forEvent(event)
        let editorial = EditorialContent.forEvent(event)

        if editorial.tone == .remembrance {
            return (
                isTurkish ? "\(symbol) Bugünün notu" : "\(symbol) Today's note",
                "\(event.title). \(editorial.fact)"
            )
        }

        if isSaved {
            return (
                isTurkish ? "\(symbol) Kaydettiğin gün bugün" : "\(symbol) A day you saved is here",
                "\(event.title) · \(editorial.prompt)"
            )
        }

        return (
            isTurkish
                ? "\(symbol) Bugün birine yazmak için bahanen var"
                : "\(symbol) You have a reason to text someone today",
            "\(event.title) · \(editorial.prompt)"
        )
    }
}

/// Maintains one rolling reminder per day without touching notifications that
/// do not belong to WhaDay's daily reminder feature.
@MainActor
enum NotificationScheduler {
    private static let center = UNUserNotificationCenter.current()

    static func requestPermission() async -> Bool {
        (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    static func authorizationStatus() async -> UNAuthorizationStatus {
        await center.notificationSettings().authorizationStatus
    }

    static func scheduleIfNeeded(configuration: ReminderConfiguration) async {
        let status = await authorizationStatus()
        guard configuration.isEnabled, ReminderAuthorizationPolicy.permitsScheduling(status) else {
            await clearScheduled()
            return
        }
        await replaceSchedule(configuration: configuration)
    }

    static func clearScheduled() async {
        let identifiers = await center.pendingNotificationRequests()
            .map(\.identifier)
            .filter { $0.hasPrefix(ReminderPlanBuilder.identifierPrefix) }
        if !identifiers.isEmpty {
            center.removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }

    private static func replaceSchedule(configuration: ReminderConfiguration) async {
        await clearScheduled()

        let calendar = Calendar.current
        let plan = ReminderPlanBuilder.make(
            configuration: configuration,
            now: Date(),
            calendar: calendar,
            events: DayEventStore.days,
            language: DayEventStore.language
        )

        for reminder in plan {
            let content = UNMutableNotificationContent()
            content.title = reminder.title
            content.body = reminder.body
            content.sound = .default
            content.userInfo = ["dayId": reminder.eventID, "type": "daily-reminder"]

            let components = calendar.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: reminder.fireDate
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(
                identifier: reminder.identifier,
                content: content,
                trigger: trigger
            )
            try? await center.add(request)
        }
    }
}
