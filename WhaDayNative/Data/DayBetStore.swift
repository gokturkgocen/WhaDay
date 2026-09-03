import Foundation
import Combine

@MainActor
final class DayBetStore: ObservableObject {
    static let shared = DayBetStore()

    @Published private(set) var betsByDay: [String: [DayBet]] = [:]

    private let groupDefaults: UserDefaults?
    private let standardDefaults: UserDefaults
    private let storageKey = "day_bets_v1"

    init(
        appGroupID: String = "group.com.gokturkgocen.whadayapp",
        standardDefaults: UserDefaults = .standard
    ) {
        self.groupDefaults = UserDefaults(suiteName: appGroupID)
        self.standardDefaults = standardDefaults
        self.betsByDay = Self.load(groupDefaults: groupDefaults, standardDefaults: standardDefaults, storageKey: storageKey)
    }

    func bets(for dayID: String) -> [DayBet] {
        betsByDay[dayID] ?? []
    }

    @discardableResult
    func addBet(
        dayID: String,
        title: String,
        stake: String,
        partyA: String,
        partyB: String,
        targetMonth: Int,
        targetDay: Int
    ) -> DayBet {
        let bet = DayBet(
            id: UUID().uuidString,
            dayID: dayID,
            title: title.trimmingCharacters(in: .whitespaces),
            stake: stake.trimmingCharacters(in: .whitespaces),
            partyA: partyA.trimmingCharacters(in: .whitespaces),
            partyB: partyB.trimmingCharacters(in: .whitespaces),
            targetMonth: targetMonth,
            targetDay: targetDay
        )

        var list = betsByDay[dayID] ?? []
        list.append(bet)
        betsByDay[dayID] = list
        persist()
        Haptics.triggerSuccess()
        return bet
    }

    func resolveBet(betID: String, dayID: String, winner: String) {
        guard var list = betsByDay[dayID],
              let idx = list.firstIndex(where: { $0.id == betID }) else {
            return
        }

        var bet = list[idx]
        bet.winner = winner
        list[idx] = bet
        betsByDay[dayID] = list
        persist()
        Haptics.triggerSuccess()
    }

    func deleteBet(id: String, dayID: String) {
        guard var list = betsByDay[dayID] else { return }
        list.removeAll { $0.id == id }
        betsByDay[dayID] = list
        persist()
        Haptics.triggerLight()
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(betsByDay) {
            groupDefaults?.set(data, forKey: storageKey)
            standardDefaults.set(data, forKey: storageKey)
        }
    }

    private static func load(
        groupDefaults: UserDefaults?,
        standardDefaults: UserDefaults,
        storageKey: String
    ) -> [String: [DayBet]] {
        let decoder = JSONDecoder()
        let data = groupDefaults?.data(forKey: storageKey) ?? standardDefaults.data(forKey: storageKey)
        return data.flatMap { try? decoder.decode([String: [DayBet]].self, from: $0) } ?? [:]
    }
}
