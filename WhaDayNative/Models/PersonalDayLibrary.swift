import Combine
import Foundation

@MainActor
final class PersonalDayLibrary: ObservableObject {
    @Published private(set) var savedIDs: Set<String>

    private let defaults: UserDefaults
    private let storageKey = "savedDayIDs"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.savedIDs = Set(defaults.stringArray(forKey: storageKey) ?? [])
    }

    func isSaved(_ event: DayEvent) -> Bool {
        savedIDs.contains(event.id)
    }

    func toggle(_ event: DayEvent) {
        if savedIDs.contains(event.id) {
            savedIDs.remove(event.id)
        } else {
            savedIDs.insert(event.id)
        }
        persist()
    }

    func savedEvents(from events: [DayEvent] = DayEventStore.days) -> [DayEvent] {
        events
            .filter { savedIDs.contains($0.id) }
            .sorted { nextOccurrenceSortKey($0) < nextOccurrenceSortKey($1) }
    }

    private func persist() {
        defaults.set(savedIDs.sorted(), forKey: storageKey)
    }

    private func nextOccurrenceSortKey(_ event: DayEvent) -> Int {
        let today = Calendar.current.dateComponents([.month, .day], from: Date())
        let current = (today.month ?? 1) * 100 + (today.day ?? 1)
        let eventValue = event.month * 100 + event.day
        return eventValue >= current ? eventValue : eventValue + 12_000
    }
}
