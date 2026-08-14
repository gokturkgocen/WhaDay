import Combine
import Foundation

enum DayDateResolver {
    static func dayID(at date: Date, calendar: Calendar) -> String {
        let components = calendar.dateComponents([.month, .day], from: date)
        return String(format: "%02d-%02d", components.month ?? 1, components.day ?? 1)
    }

    static func nextDayBoundary(after date: Date, calendar: Calendar) -> Date? {
        calendar.nextDate(
            after: date,
            matching: DateComponents(hour: 0, minute: 0, second: 1),
            matchingPolicy: .nextTime,
            repeatedTimePolicy: .first,
            direction: .forward
        )
    }
}

@MainActor
final class AppDateContext: ObservableObject {
    @Published private(set) var now: Date
    @Published private(set) var calendar: Calendar
    @Published private(set) var locale: Locale

    init(
        now: Date = Date(),
        calendar: Calendar = .current,
        locale: Locale = .current
    ) {
        self.now = now
        self.calendar = calendar
        self.locale = locale
    }

    var dayID: String {
        DayDateResolver.dayID(at: now, calendar: calendar)
    }

    var nextDayBoundary: Date? {
        DayDateResolver.nextDayBoundary(after: now, calendar: calendar)
    }

    func refresh(
        now: Date = Date(),
        calendar: Calendar = .current,
        locale: Locale = .current
    ) {
        self.calendar = calendar
        self.locale = locale
        self.now = now
    }
}
