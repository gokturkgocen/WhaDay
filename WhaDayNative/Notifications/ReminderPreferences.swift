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
        self.isEnabled = defaults.bool(forKey: Key.enabled)
        self.hour = defaults.object(forKey: Key.hour) == nil ? 9 : defaults.integer(forKey: Key.hour)
        self.minute = defaults.object(forKey: Key.minute) == nil ? 0 : defaults.integer(forKey: Key.minute)
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
}
