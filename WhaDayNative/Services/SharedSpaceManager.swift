import CloudKit
import Combine
import Foundation
import WidgetKit

@MainActor
final class SharedSpaceManager: ObservableObject {
    static let shared = SharedSpaceManager()

    @Published private(set) var spaces: [SharedSpace] = []
    @Published private(set) var eventsBySpace: [String: [SharedSpaceEvent]] = [:]
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var lastError: String?

    private let database: CKDatabase
    private let container: CKContainer
    private let groupDefaults: UserDefaults?
    private let standardDefaults: UserDefaults
    private let isCloudKitEnabled: Bool

    private let spacesStorageKey = "shared_spaces_v1"
    private let eventsStorageKey = "shared_events_v1"

    init(
        containerIdentifier: String = "iCloud.com.gokturkgocen.whadayapp",
        appGroupID: String = "group.com.gokturkgocen.whadayapp",
        standardDefaults: UserDefaults = .standard,
        enableCloudSync: Bool = true
    ) {
        self.container = CKContainer(identifier: containerIdentifier)
        self.database = container.publicCloudDatabase
        self.groupDefaults = UserDefaults(suiteName: appGroupID)
        self.standardDefaults = standardDefaults
        self.isCloudKitEnabled = enableCloudSync

        let (loadedSpaces, loadedEvents) = Self.loadCache(groupDefaults: groupDefaults, standardDefaults: standardDefaults)
        self.spaces = loadedSpaces
        self.eventsBySpace = loadedEvents
    }

    // MARK: - Query

    func events(for spaceID: String) -> [SharedSpaceEvent] {
        eventsBySpace[spaceID] ?? []
    }

    /// Merges all shared space events as DayEvents to be reflected across home and calendar.
    func allSharedDays() -> [DayEvent] {
        var days: [DayEvent] = []
        for space in spaces {
            let spaceEvents = events(for: space.id)
            for ev in spaceEvents {
                days.append(ev.toDayEvent(spaceTitle: space.title))
            }
        }
        return days
    }

    /// Finds the closest upcoming shared event across all spaces.
    func nextUpcomingEvent(referenceDate: Date = Date()) -> (space: SharedSpace, event: SharedSpaceEvent, daysRemaining: Int)? {
        var candidates: [(space: SharedSpace, event: SharedSpaceEvent, daysRemaining: Int)] = []

        for space in spaces {
            for ev in events(for: space.id) {
                let remaining = ev.daysRemaining(from: referenceDate)
                candidates.append((space, ev, remaining))
            }
        }

        return candidates.min(by: { $0.daysRemaining < $1.daysRemaining })
    }

    // MARK: - Actions

    func createSpace(title: String, emoji: String, creatorName: String) async throws -> SharedSpace {
        let space = SharedSpace(
            id: UUID().uuidString,
            title: title.trimmingCharacters(in: .whitespaces),
            emoji: emoji,
            creatorName: creatorName.trimmingCharacters(in: .whitespaces)
        )

        spaces.append(space)
        persist()

        guard isCloudKitEnabled else {
            Haptics.triggerSuccess()
            return space
        }

        let record = CKRecord(recordType: "SharedSpace", recordID: CKRecord.ID(recordName: space.id))
        record["spaceID"] = space.id as NSString
        record["title"] = space.title as NSString
        record["emoji"] = space.emoji as NSString
        record["creatorName"] = space.creatorName as NSString
        record["members"] = space.members as NSArray
        record["creationDate"] = space.createdAt as NSDate

        do {
            _ = try await database.save(record)
        } catch {
            self.lastError = error.localizedDescription
        }

        Haptics.triggerSuccess()
        return space
    }

    func joinSpace(space: SharedSpace, memberName: String) async throws {
        var updated = space
        let trimmedMember = memberName.trimmingCharacters(in: .whitespaces)
        if !trimmedMember.isEmpty && !updated.members.contains(trimmedMember) {
            updated.members.append(trimmedMember)
        }

        if let idx = spaces.firstIndex(where: { $0.id == space.id }) {
            spaces[idx] = updated
        } else {
            spaces.append(updated)
        }
        persist()

        // Fetch events for this newly joined space
        await fetchEvents(for: space.id)

        guard isCloudKitEnabled else {
            Haptics.triggerSuccess()
            return
        }

        // Update members list in CloudKit
        do {
            let recordID = CKRecord.ID(recordName: space.id)
            let record = try await database.record(for: recordID)
            var currentMembers = record["members"] as? [String] ?? []
            if !trimmedMember.isEmpty && !currentMembers.contains(trimmedMember) {
                currentMembers.append(trimmedMember)
                record["members"] = currentMembers as NSArray
                _ = try await database.save(record)
            }
        } catch {
            self.lastError = error.localizedDescription
        }

        Haptics.triggerSuccess()
    }

    func addEvent(
        spaceID: String,
        month: Int,
        day: Int,
        title: String,
        description: String,
        emoji: String,
        author: String
    ) async throws -> SharedSpaceEvent {
        let event = SharedSpaceEvent(
            id: UUID().uuidString,
            spaceID: spaceID,
            month: month,
            day: day,
            title: title.trimmingCharacters(in: .whitespaces),
            description: description.trimmingCharacters(in: .whitespaces),
            emoji: emoji,
            addedBy: author.trimmingCharacters(in: .whitespaces)
        )

        var list = eventsBySpace[spaceID] ?? []
        list.append(event)
        eventsBySpace[spaceID] = list
        persist()

        guard isCloudKitEnabled else {
            Haptics.triggerSuccess()
            return event
        }

        let record = CKRecord(recordType: "SharedSpaceEvent", recordID: CKRecord.ID(recordName: event.id))
        record["spaceID"] = event.spaceID as NSString
        record["month"] = event.month as NSNumber
        record["day"] = event.day as NSNumber
        record["title"] = event.title as NSString
        record["description"] = event.description as NSString
        record["emoji"] = event.emoji as NSString
        record["addedBy"] = event.addedBy as NSString
        record["creationDate"] = event.createdAt as NSDate

        do {
            _ = try await database.save(record)
        } catch {
            self.lastError = error.localizedDescription
        }

        Haptics.triggerSuccess()
        return event
    }

    func fetchEvents(for spaceID: String) async {
        guard isCloudKitEnabled else { return }
        isLoading = true

        let predicate = NSPredicate(format: "spaceID == %@", spaceID)
        let query = CKQuery(recordType: "SharedSpaceEvent", predicate: predicate)

        do {
            if #available(iOS 15.0, *) {
                let (results, _) = try await database.records(matching: query)
                var fetched: [SharedSpaceEvent] = []
                for (_, res) in results {
                    if case .success(let record) = res,
                       let ev = Self.parseEvent(record: record) {
                        fetched.append(ev)
                    }
                }

                var current = eventsBySpace[spaceID] ?? []
                for ev in fetched where !current.contains(where: { $0.id == ev.id }) {
                    current.append(ev)
                }
                eventsBySpace[spaceID] = current
                persist()
            }
        } catch {
            self.lastError = error.localizedDescription
        }

        isLoading = false
    }

    func leaveSpace(id: String) {
        spaces.removeAll { $0.id == id }
        eventsBySpace.removeValue(forKey: id)
        persist()
        Haptics.triggerLight()
    }

    // MARK: - Cache & Parsing

    private func persist() {
        let encoder = JSONEncoder()
        if let spacesData = try? encoder.encode(spaces) {
            groupDefaults?.set(spacesData, forKey: spacesStorageKey)
            standardDefaults.set(spacesData, forKey: spacesStorageKey)
        }
        if let eventsData = try? encoder.encode(eventsBySpace) {
            groupDefaults?.set(eventsData, forKey: eventsStorageKey)
            standardDefaults.set(eventsData, forKey: eventsStorageKey)
        }

        // Update widget store with upcoming shared event
        if let upcoming = nextUpcomingEvent() {
            let widgetData = UpcomingSharedEventData(
                spaceID: upcoming.space.id,
                spaceTitle: upcoming.space.title,
                spaceEmoji: upcoming.space.emoji,
                eventTitle: upcoming.event.title,
                eventEmoji: upcoming.event.emoji,
                month: upcoming.event.month,
                day: upcoming.event.day,
                daysRemaining: upcoming.daysRemaining
            )
            SharedSpaceWidgetDataStore.save(widgetData)
        } else {
            SharedSpaceWidgetDataStore.save(nil)
        }

        WidgetCenter.shared.reloadAllTimelines()
    }

    private static func loadCache(
        groupDefaults: UserDefaults?,
        standardDefaults: UserDefaults
    ) -> ([SharedSpace], [String: [SharedSpaceEvent]]) {
        let decoder = JSONDecoder()

        let spacesData = groupDefaults?.data(forKey: "shared_spaces_v1") ?? standardDefaults.data(forKey: "shared_spaces_v1")
        let loadedSpaces = spacesData.flatMap { try? decoder.decode([SharedSpace].self, from: $0) } ?? []

        let eventsData = groupDefaults?.data(forKey: "shared_events_v1") ?? standardDefaults.data(forKey: "shared_events_v1")
        let loadedEvents = eventsData.flatMap { try? decoder.decode([String: [SharedSpaceEvent]].self, from: $0) } ?? [:]

        return (loadedSpaces, loadedEvents)
    }

    private static func parseEvent(record: CKRecord) -> SharedSpaceEvent? {
        guard
            let spaceID = record["spaceID"] as? String,
            let month = record["month"] as? Int,
            let day = record["day"] as? Int,
            let title = record["title"] as? String,
            let description = record["description"] as? String,
            let emoji = record["emoji"] as? String,
            let addedBy = record["addedBy"] as? String
        else {
            return nil
        }

        let createdAt = (record["creationDate"] as? Date) ?? record.creationDate ?? Date()

        return SharedSpaceEvent(
            id: record.recordID.recordName,
            spaceID: spaceID,
            month: month,
            day: day,
            title: title,
            description: description,
            emoji: emoji,
            addedBy: addedBy,
            createdAt: createdAt
        )
    }
}
