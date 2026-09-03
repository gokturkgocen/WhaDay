import Foundation

struct SharedSpaceEvent: Identifiable, Codable, Equatable, Sendable {
    let id: String
    let spaceID: String
    let month: Int
    let day: Int
    var title: String
    var description: String
    var emoji: String
    let addedBy: String
    let createdAt: Date

    init(
        id: String = UUID().uuidString,
        spaceID: String,
        month: Int,
        day: Int,
        title: String,
        description: String,
        emoji: String,
        addedBy: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.spaceID = spaceID
        self.month = month
        self.day = day
        self.title = title
        self.description = description
        self.emoji = emoji
        self.addedBy = addedBy
        self.createdAt = createdAt
    }

    /// Calculates days remaining until the next occurrence of this event.
    func daysRemaining(from referenceDate: Date = Date(), calendar: Calendar = .current) -> Int {
        let currentYear = calendar.component(.year, from: referenceDate)
        var targetComps = DateComponents(year: currentYear, month: month, day: day)

        guard let targetThisYear = calendar.date(from: targetComps) else { return 0 }

        let startOfToday = calendar.startOfDay(for: referenceDate)
        let startOfTarget = calendar.startOfDay(for: targetThisYear)

        if startOfTarget >= startOfToday {
            let diff = calendar.dateComponents([.day], from: startOfToday, to: startOfTarget)
            return max(0, diff.day ?? 0)
        } else {
            // Next year
            targetComps.year = currentYear + 1
            if let targetNextYear = calendar.date(from: targetComps) {
                let startOfNext = calendar.startOfDay(for: targetNextYear)
                let diff = calendar.dateComponents([.day], from: startOfToday, to: startOfNext)
                return max(0, diff.day ?? 0)
            }
            return 0
        }
    }

    /// Formatted date string (e.g. "23 Ağustos" or "August 23").
    var formattedDate: String {
        var comps = DateComponents()
        comps.month = month
        comps.day = day
        let formatter = DateFormatter()
        formatter.locale = DayEventStore.dateLocale
        formatter.dateFormat = "d MMMM"
        let date = Calendar.current.date(from: comps) ?? Date()
        return formatter.string(from: date)
    }

    /// Converts into a standard DayEvent for rendering across cards, widgets, and lists.
    func toDayEvent(spaceTitle: String) -> DayEvent {
        let dayID = String(format: "%02d-%02d", month, day)
        let meta = DayMetadata(
            id: dayID,
            authority: .cultural,
            category: .celebrations,
            sensitivity: .standard,
            shareability: 5,
            audience: ["shared-space"],
            symbol: "person.2.fill",
            reviewState: .curated,
            scope: nil,
            source: nil
        )

        let hook: String
        if !addedBy.trimmingCharacters(in: .whitespaces).isEmpty {
            hook = DayEventStore.language == "tr"
                ? "\(addedBy) tarafından '\(spaceTitle)' ortak takvimine eklendi."
                : "Added by \(addedBy) to '\(spaceTitle)' shared calendar."
        } else {
            hook = DayEventStore.language == "tr"
                ? "'\(spaceTitle)' ortak takviminizdeki özel bir gün."
                : "A special day in your '\(spaceTitle)' shared calendar."
        }

        return DayEvent(
            id: dayID,
            month: month,
            day: day,
            title: title,
            description: description,
            emoji: emoji,
            category: "celebration",
            sharingHook: hook,
            metadata: meta
        )
    }
}
