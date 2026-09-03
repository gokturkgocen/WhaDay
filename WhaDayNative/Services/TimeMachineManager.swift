import Foundation
import Combine

struct PastMemory: Identifiable, Equatable, Sendable {
    let id: String
    let dayID: String
    let month: Int
    let day: Int
    let year: Int
    let title: String
    let emoji: String
    let spaceTitle: String?
    let notes: [CapsuleNote]

    var formattedDate: String {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        let formatter = DateFormatter()
        formatter.locale = DayEventStore.dateLocale
        formatter.dateFormat = "d MMMM yyyy"
        let date = Calendar.current.date(from: comps) ?? Date()
        return formatter.string(from: date)
    }

    var shortDate: String {
        var comps = DateComponents()
        comps.month = month
        comps.day = day
        let formatter = DateFormatter()
        formatter.locale = DayEventStore.dateLocale
        formatter.dateFormat = "d MMMM"
        let date = Calendar.current.date(from: comps) ?? Date()
        return formatter.string(from: date)
    }
}

@MainActor
final class TimeMachineManager: ObservableObject {
    static let shared = TimeMachineManager()

    @Published private(set) var memories: [PastMemory] = []

    init() {
        refresh()
    }

    func refresh() {
        var collected: [PastMemory] = []
        let now = Date()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: now)

        let capsuleManager = CapsuleCloudManager.shared
        let spaceManager = SharedSpaceManager.shared
        let customStore = CustomDayStore.shared

        // 1. Scan shared spaces events
        for space in spaceManager.spaces {
            let events = spaceManager.events(for: space.id)
            for ev in events {
                let dayID = String(format: "%02d-%02d", ev.month, ev.day)
                let notes = capsuleManager.notes(for: dayID)
                let eventYear = calendar.component(.year, from: ev.createdAt)

                // Memory is past if target date this year is already passed, or if created in prior year
                var targetComps = DateComponents(year: currentYear, month: ev.month, day: ev.day)
                if let targetDate = calendar.date(from: targetComps),
                   calendar.startOfDay(for: targetDate) <= calendar.startOfDay(for: now) {
                    collected.append(PastMemory(
                        id: "shared-\(ev.id)",
                        dayID: dayID,
                        month: ev.month,
                        day: ev.day,
                        year: eventYear,
                        title: ev.title,
                        emoji: ev.emoji,
                        spaceTitle: space.title,
                        notes: notes
                    ))
                }
            }
        }

        // 2. Scan custom days
        for (dayID, customRecord) in customStore.customDays {
            let notes = capsuleManager.notes(for: dayID)
            var targetComps = DateComponents(year: currentYear, month: customRecord.month, day: customRecord.day)
            if let targetDate = calendar.date(from: targetComps),
               calendar.startOfDay(for: targetDate) <= calendar.startOfDay(for: now) {
                let year = calendar.component(.year, from: customRecord.createdAt)
                collected.append(PastMemory(
                    id: "custom-\(dayID)",
                    dayID: dayID,
                    month: customRecord.month,
                    day: customRecord.day,
                    year: year,
                    title: customRecord.title,
                    emoji: customRecord.emoji,
                    spaceTitle: nil,
                    notes: notes
                ))
            }
        }

        self.memories = collected.sorted(by: { $0.year > $1.year || ($0.year == $1.year && ($0.month > $1.month || ($0.month == $1.month && $0.day > $1.day))) })
    }

    /// Finds memories that match today's day and month (anniversary / On This Day).
    func memoriesOnThisDay(referenceDate: Date = Date(), calendar: Calendar = .current) -> [PastMemory] {
        let currentMonth = calendar.component(.month, from: referenceDate)
        let currentDay = calendar.component(.day, from: referenceDate)
        let currentYear = calendar.component(.year, from: referenceDate)

        return memories.filter { mem in
            mem.month == currentMonth && mem.day == currentDay && mem.year < currentYear
        }
    }

    /// Generates nostalgic notification copy if there are past memories on a given date.
    func anniversaryNotificationContent(referenceDate: Date = Date(), calendar: Calendar = .current) -> (title: String, body: String)? {
        let matches = memoriesOnThisDay(referenceDate: referenceDate, calendar: calendar)
        guard let first = matches.first else { return nil }

        let yearsAgo = max(1, calendar.component(.year, from: referenceDate) - first.year)
        let timeLabel = DayEventStore.language == "tr"
            ? "Tam \(yearsAgo) yıl önce bugün"
            : "\(yearsAgo) year\(yearsAgo > 1 ? "s" : "") ago today"

        if let note = first.notes.first {
            let author = note.authorName.isEmpty ? (DayEventStore.language == "tr" ? "bir arkadaşın" : "a friend") : note.authorName
            return (
                title: DayEventStore.language == "tr" ? "🕰️ Zaman Makinesi" : "🕰️ Time Machine",
                body: DayEventStore.language == "tr"
                    ? "\(timeLabel) '\(first.title)' için \(author) bir not bırakmıştı. Hatırladın mı?"
                    : "\(timeLabel), \(author) left a note for '\(first.title)'. Remember?"
            )
        } else {
            return (
                title: DayEventStore.language == "tr" ? "🕰️ Zaman Makinesi" : "🕰️ Time Machine",
                body: DayEventStore.language == "tr"
                    ? "\(timeLabel) '\(first.title)' gününüzü kaydetmiştiniz."
                    : "\(timeLabel), you celebrated '\(first.title)'."
            )
        }
    }
}
