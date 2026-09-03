import Combine
import Foundation

@MainActor
final class CustomDayStore: ObservableObject {
    static let shared = CustomDayStore()

    @Published private(set) var customDays: [String: CustomDayRecord] = [:]

    private let standardDefaults: UserDefaults
    private let groupDefaults: UserDefaults?
    private let storageKey = "customDays_v1"

    init(
        standardDefaults: UserDefaults = .standard,
        appGroupID: String = "group.com.gokturkgocen.whadayapp"
    ) {
        self.standardDefaults = standardDefaults
        self.groupDefaults = UserDefaults(suiteName: appGroupID)
        self.customDays = loadPersistedDays()
    }

    // MARK: - Query

    func customDay(for id: String) -> CustomDayRecord? {
        customDays[id]
    }

    func isCustom(dayID: String) -> Bool {
        customDays[dayID] != nil
    }

    /// Returns the custom DayEvent if defined, otherwise falls back to the default catalog event.
    func effectiveEvent(for id: String) -> DayEvent? {
        if let custom = customDays[id] {
            return custom.toDayEvent()
        }
        return DayEventStore.event(id: id)
    }

    /// Merges custom days into a list of DayEvents (overriding default events for matched dates).
    func effectiveDays(from baseDays: [DayEvent] = DayEventStore.days) -> [DayEvent] {
        guard !customDays.isEmpty else { return baseDays }
        return baseDays.map { day in
            if let custom = customDays[day.id] {
                return custom.toDayEvent()
            }
            return day
        }
    }

    // MARK: - Mutations

    func save(_ record: CustomDayRecord) {
        customDays[record.id] = record
        persist()
        Haptics.triggerSuccess()
    }

    func remove(for dayID: String) {
        customDays.removeValue(forKey: dayID)
        persist()
        Haptics.triggerLight()
    }

    // MARK: - Persistence

    private func persist() {
        guard let data = try? JSONEncoder().encode(customDays) else { return }
        standardDefaults.set(data, forKey: storageKey)
        groupDefaults?.set(data, forKey: storageKey)
    }

    private func loadPersistedDays() -> [String: CustomDayRecord] {
        if let data = groupDefaults?.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([String: CustomDayRecord].self, from: data) {
            return decoded
        }
        if let data = standardDefaults.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([String: CustomDayRecord].self, from: data) {
            return decoded
        }
        return [:]
    }
}
