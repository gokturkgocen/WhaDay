import Foundation

struct CapsuleNote: Identifiable, Codable, Equatable, Sendable {
    let id: String
    let capsuleID: String
    let authorName: String
    let content: String
    let targetMonth: Int
    let targetDay: Int
    let createdAt: Date

    init(
        id: String = UUID().uuidString,
        capsuleID: String,
        authorName: String,
        content: String,
        targetMonth: Int,
        targetDay: Int,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.capsuleID = capsuleID
        self.authorName = authorName
        self.content = content
        self.targetMonth = targetMonth
        self.targetDay = targetDay
        self.createdAt = createdAt
    }

    /// Determines if the note is still locked based on the current calendar date.
    func isLocked(at referenceDate: Date = Date(), calendar: Calendar = .current) -> Bool {
        let currentMonth = calendar.component(.month, from: referenceDate)
        let currentDay = calendar.component(.day, from: referenceDate)

        if currentMonth < targetMonth {
            return true
        } else if currentMonth == targetMonth {
            return currentDay < targetDay
        } else {
            // Target month has passed for this year, unlocked
            return false
        }
    }

    /// Formatted target date string (e.g. "5 Eylül" or "September 5").
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
