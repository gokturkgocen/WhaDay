import Foundation

struct WeeklyPick: Identifiable, Equatable {
    let event: DayEvent
    let date: Date
    let dayOffset: Int

    var id: String { event.id }
}

enum WeeklyPicks {
    static func make(
        from startDate: Date = Date(),
        calendar: Calendar = .current,
        events: [DayEvent] = DayEventStore.days,
        limit: Int = 3
    ) -> [WeeklyPick] {
        let lookup = Dictionary(uniqueKeysWithValues: events.map { ($0.id, $0) })

        let candidates = (0..<7).compactMap { offset -> (WeeklyPick, Int)? in
            guard let date = calendar.date(byAdding: .day, value: offset, to: startDate) else { return nil }
            let components = calendar.dateComponents([.month, .day], from: date)
            guard let month = components.month, let day = components.day else { return nil }
            let id = String(format: "%02d-%02d", month, day)
            guard let event = lookup[id] else { return nil }

            let editorial = EditorialContent.forEvent(event)
            guard editorial.tone != .remembrance else { return nil }

            return (WeeklyPick(event: event, date: date, dayOffset: offset), score(event, editorial: editorial))
        }

        return candidates
            .sorted { lhs, rhs in
                if lhs.1 == rhs.1 { return lhs.0.dayOffset < rhs.0.dayOffset }
                return lhs.1 > rhs.1
            }
            .prefix(max(0, limit))
            .map(\.0)
            .sorted { $0.dayOffset < $1.dayOffset }
    }

    private static func score(_ event: DayEvent, editorial: EditorialContent) -> Int {
        var result = 0

        switch editorial.tone {
        case .playful: result += 5
        case .warm: result += 4
        case .curious: result += 3
        case .mindful: result += 1
        case .remembrance: result -= 100
        }

        if SharePersonalization.suggestions(for: event).first?.id != "first" {
            result += 4
        }

        switch event.category {
        case "fun", "social", "creative", "lifestyle", "science", "culture":
            result += 2
        case "growth", "reflection", "mindfulness", "wellness":
            result += 1
        case "awareness":
            // Generic awareness entries often need context rather than a casual
            // “this made me think of you” share. A strong personal match can
            // still lift one into the shortlist (for example, Lefthanders Day).
            result -= 2
        default:
            break
        }

        switch DayProvenance.forEvent(event).kind {
        case .editorial:
            result += 1
        case .official:
            break
        case .cultural:
            // Country and faith calendar entries remain discoverable in the full
            // calendar but should not dominate a generic social-sharing shortlist.
            result -= 6
        }

        return result
    }
}
