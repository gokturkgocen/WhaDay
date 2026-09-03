import CloudKit
import Combine
import Foundation

@MainActor
final class CapsuleCloudManager: ObservableObject {
    static let shared = CapsuleCloudManager()

    @Published private(set) var notesByCapsule: [String: [CapsuleNote]] = [:]
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var lastError: String?

    private let database: CKDatabase
    private let container: CKContainer
    private let recordType = "CapsuleNote"
    private let cacheDefaults: UserDefaults
    private let cacheKey = "capsule_notes_cache_v1"
    private let isCloudKitEnabled: Bool

    init(
        containerIdentifier: String = "iCloud.com.gokturkgocen.whadayapp",
        cacheDefaults: UserDefaults = .standard,
        enableCloudSync: Bool = true
    ) {
        self.container = CKContainer(identifier: containerIdentifier)
        self.database = container.publicCloudDatabase
        self.cacheDefaults = cacheDefaults
        self.isCloudKitEnabled = enableCloudSync
        self.notesByCapsule = loadCache()
    }

    // MARK: - Query

    func notes(for capsuleID: String) -> [CapsuleNote] {
        notesByCapsule[capsuleID] ?? []
    }

    func lockedCount(for capsuleID: String, referenceDate: Date = Date()) -> Int {
        notes(for: capsuleID).filter { $0.isLocked(at: referenceDate) }.count
    }

    func unlockedNotes(for capsuleID: String, referenceDate: Date = Date()) -> [CapsuleNote] {
        notes(for: capsuleID).filter { !$0.isLocked(at: referenceDate) }
    }

    // MARK: - Fetch From CloudKit

    func fetchNotes(for capsuleID: String) async {
        guard isCloudKitEnabled else { return }
        isLoading = true
        lastError = nil

        let predicate = NSPredicate(format: "capsuleID == %@", capsuleID)
        let query = CKQuery(recordType: recordType, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]

        do {
            let matchResults: [(CKRecord.ID, Result<CKRecord, Error>)]
            if #available(iOS 15.0, *) {
                let (results, _) = try await database.records(matching: query)
                matchResults = results
            } else {
                matchResults = []
            }

            var fetched: [CapsuleNote] = []
            for (_, result) in matchResults {
                if case .success(let record) = result,
                   let note = Self.parse(record: record) {
                    fetched.append(note)
                }
            }

            // Merge with local cache to avoid losing optimistic updates
            var current = notesByCapsule[capsuleID] ?? []
            for item in fetched where !current.contains(where: { $0.id == item.id }) {
                current.append(item)
            }
            notesByCapsule[capsuleID] = current
            persistCache()
        } catch {
            // Graceful fallback to local cache if offline or CloudKit not yet provisioned
            self.lastError = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Submit Note

    func submitNote(
        capsuleID: String,
        authorName: String,
        content: String,
        targetMonth: Int,
        targetDay: Int
    ) async throws {
        let note = CapsuleNote(
            id: UUID().uuidString,
            capsuleID: capsuleID,
            authorName: authorName.trimmingCharacters(in: .whitespaces),
            content: content.trimmingCharacters(in: .whitespaces),
            targetMonth: targetMonth,
            targetDay: targetDay,
            createdAt: Date()
        )

        // Optimistic local update
        var list = notesByCapsule[capsuleID] ?? []
        list.append(note)
        notesByCapsule[capsuleID] = list
        persistCache()

        guard isCloudKitEnabled else {
            Haptics.triggerSuccess()
            return
        }

        // CloudKit Record creation
        let record = CKRecord(recordType: recordType, recordID: CKRecord.ID(recordName: note.id))
        record["capsuleID"] = note.capsuleID as NSString
        record["authorName"] = note.authorName as NSString
        record["content"] = note.content as NSString
        record["targetMonth"] = note.targetMonth as NSNumber
        record["targetDay"] = note.targetDay as NSNumber
        record["creationDate"] = note.createdAt as NSDate

        do {
            _ = try await database.save(record)
        } catch {
            // Note is already safe in local cache, but track error
            self.lastError = error.localizedDescription
        }

        Haptics.triggerSuccess()
    }

    // MARK: - Parsing & Cache

    private static func parse(record: CKRecord) -> CapsuleNote? {
        guard
            let capsuleID = record["capsuleID"] as? String,
            let authorName = record["authorName"] as? String,
            let content = record["content"] as? String,
            let targetMonth = record["targetMonth"] as? Int,
            let targetDay = record["targetDay"] as? Int
        else {
            return nil
        }

        let createdAt = (record["creationDate"] as? Date) ?? record.creationDate ?? Date()

        return CapsuleNote(
            id: record.recordID.recordName,
            capsuleID: capsuleID,
            authorName: authorName,
            content: content,
            targetMonth: targetMonth,
            targetDay: targetDay,
            createdAt: createdAt
        )
    }

    private func persistCache() {
        guard let data = try? JSONEncoder().encode(notesByCapsule) else { return }
        cacheDefaults.set(data, forKey: cacheKey)
    }

    private func loadCache() -> [String: [CapsuleNote]] {
        guard
            let data = cacheDefaults.data(forKey: cacheKey),
            let decoded = try? JSONDecoder().decode([String: [CapsuleNote]].self, from: data)
        else {
            return [:]
        }
        return decoded
    }
}
