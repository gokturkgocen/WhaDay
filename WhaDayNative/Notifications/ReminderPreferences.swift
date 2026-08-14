import Combine
import Foundation

struct ReminderConfiguration: Equatable, Sendable {
    let isEnabled: Bool
    let hour: Int
    let minute: Int
    let savedIDs: Set<String>
}

@MainActor
final class ReminderPreferences: ObservableObject {
    @Published private(set) var isEnabled: Bool
    @Published private(set) var hour: Int
    @Published private(set) var minute: Int

    private let defaults: UserDefaults
    private enum Key {
        static let enabled = "dailyReminderEnabled"
        static let hour = "dailyReminderHour"
        static let minute = "dailyReminderMinute"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let storedEnabled = defaults.object(forKey: Key.enabled)
        let storedHour = defaults.object(forKey: Key.hour)
        let storedMinute = defaults.object(forKey: Key.minute)

        self.isEnabled = (storedEnabled as? NSNumber)?.boolValue ?? false
        self.hour = Self.sanitizedInteger(storedHour, defaultValue: 9, range: 0...23)
        self.minute = Self.sanitizedInteger(storedMinute, defaultValue: 0, range: 0...59)

        if storedEnabled != nil, !(storedEnabled is NSNumber) {
            defaults.set(false, forKey: Key.enabled)
        }
        if storedHour != nil, (storedHour as? NSNumber)?.intValue != hour {
            defaults.set(hour, forKey: Key.hour)
        }
        if storedMinute != nil, (storedMinute as? NSNumber)?.intValue != minute {
            defaults.set(minute, forKey: Key.minute)
        }
    }

    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        defaults.set(enabled, forKey: Key.enabled)
    }

    func setTime(hour: Int, minute: Int) {
        self.hour = min(max(hour, 0), 23)
        self.minute = min(max(minute, 0), 59)
        defaults.set(self.hour, forKey: Key.hour)
        defaults.set(self.minute, forKey: Key.minute)
    }

    func configuration(savedIDs: Set<String>) -> ReminderConfiguration {
        ReminderConfiguration(
            isEnabled: isEnabled,
            hour: hour,
            minute: minute,
            savedIDs: savedIDs
        )
    }

    private static func sanitizedInteger(
        _ value: Any?,
        defaultValue: Int,
        range: ClosedRange<Int>
    ) -> Int {
        guard let number = value as? NSNumber else { return defaultValue }
        return min(max(number.intValue, range.lowerBound), range.upperBound)
    }
}
