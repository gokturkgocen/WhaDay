import Foundation

struct DayEvent: Codable, Identifiable, Equatable {
    let id: String
    let month: Int
    let day: Int
    let title: String
    let description: String
    let emoji: String
    let category: String
    let sharingHook: String
}
