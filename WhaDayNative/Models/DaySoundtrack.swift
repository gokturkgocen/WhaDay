import Foundation
import UIKit

struct DaySoundtrack: Identifiable, Codable, Equatable, Sendable {
    let id: String
    let dayID: String
    let trackTitle: String
    let artistName: String
    let musicURL: String?
    let addedBy: String
    let createdAt: Date

    init(
        id: String = UUID().uuidString,
        dayID: String,
        trackTitle: String,
        artistName: String,
        musicURL: String? = nil,
        addedBy: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.dayID = dayID
        self.trackTitle = trackTitle
        self.artistName = artistName
        self.musicURL = musicURL
        self.addedBy = addedBy
        self.createdAt = createdAt
    }

    /// Generates URL to play track or search in music apps.
    func targetPlaybackURL() -> URL? {
        if let raw = musicURL, let url = URL(string: raw), !raw.isEmpty {
            return url
        }
        let query = "\(artistName) \(trackTitle)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "https://open.spotify.com/search/\(query)")
    }
}

@MainActor
final class DaySoundtrackStore: ObservableObject {
    static let shared = DaySoundtrackStore()

    @Published private(set) var soundtracksByDay: [String: DaySoundtrack] = [:]

    private let groupDefaults: UserDefaults?
    private let standardDefaults: UserDefaults
    private let storageKey = "day_soundtracks_v1"

    init(
        appGroupID: String = "group.com.gokturkgocen.whadayapp",
        standardDefaults: UserDefaults = .standard
    ) {
        self.groupDefaults = UserDefaults(suiteName: appGroupID)
        self.standardDefaults = standardDefaults

        let decoder = JSONDecoder()
        let data = groupDefaults?.data(forKey: storageKey) ?? standardDefaults.data(forKey: storageKey)
        self.soundtracksByDay = data.flatMap { try? decoder.decode([String: DaySoundtrack].self, from: $0) } ?? [:]
    }

    func soundtrack(for dayID: String) -> DaySoundtrack? {
        soundtracksByDay[dayID]
    }

    @discardableResult
    func setSoundtrack(
        dayID: String,
        trackTitle: String,
        artistName: String,
        musicURL: String?,
        addedBy: String
    ) -> DaySoundtrack {
        let st = DaySoundtrack(
            dayID: dayID,
            trackTitle: trackTitle.trimmingCharacters(in: .whitespaces),
            artistName: artistName.trimmingCharacters(in: .whitespaces),
            musicURL: musicURL?.trimmingCharacters(in: .whitespaces),
            addedBy: addedBy.trimmingCharacters(in: .whitespaces)
        )
        soundtracksByDay[dayID] = st
        persist()
        Haptics.triggerSuccess()
        return st
    }

    func removeSoundtrack(for dayID: String) {
        soundtracksByDay.removeValue(forKey: dayID)
        persist()
        Haptics.triggerLight()
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(soundtracksByDay) {
            groupDefaults?.set(data, forKey: storageKey)
            standardDefaults.set(data, forKey: storageKey)
        }
    }
}
