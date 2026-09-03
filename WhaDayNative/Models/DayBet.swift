import Foundation

struct DayBet: Identifiable, Codable, Equatable, Sendable {
    let id: String
    let dayID: String
    let title: String
    let stake: String
    let partyA: String
    let partyB: String
    let targetMonth: Int
    let targetDay: Int
    var winner: String?
    let createdAt: Date

    init(
        id: String = UUID().uuidString,
        dayID: String,
        title: String,
        stake: String,
        partyA: String,
        partyB: String,
        targetMonth: Int,
        targetDay: Int,
        winner: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.dayID = dayID
        self.title = title
        self.stake = stake
        self.partyA = partyA
        self.partyB = partyB
        self.targetMonth = targetMonth
        self.targetDay = targetDay
        self.winner = winner
        self.createdAt = createdAt
    }

    var isResolved: Bool {
        winner != nil
    }

    func loser() -> String? {
        guard let win = winner else { return nil }
        if win == partyA { return partyB }
        if win == partyB { return partyA }
        return nil
    }

    /// Determines if the bet is still sealed and locked until target date arrives.
    func isLocked(at referenceDate: Date = Date(), calendar: Calendar = .current) -> Bool {
        let currentMonth = calendar.component(.month, from: referenceDate)
        let currentDay = calendar.component(.day, from: referenceDate)

        if currentMonth < targetMonth {
            return true
        } else if currentMonth == targetMonth {
            return currentDay < targetDay
        } else {
            return false
        }
    }

    var formattedTargetDate: String {
        var comps = DateComponents()
        comps.month = targetMonth
        comps.day = targetDay
        let formatter = DateFormatter()
        formatter.locale = DayEventStore.dateLocale
        formatter.dateFormat = "d MMMM"
        let date = Calendar.current.date(from: comps) ?? Date()
        return formatter.string(from: date)
    }
}
