import Foundation

struct SharePersonalization: Identifiable, Equatable {
    let id: String
    let label: String
    let note: String?

    static func suggestions(for event: DayEvent) -> [SharePersonalization] {
        let title = event.title.lowercased()
        let language = DayEventStore.language

        let specific: SharePersonalization
        if containsAny(title, ["solak", "lefthander", "left-hander"]) {
            specific = item("left", "Solak arkadaşım", "My left-handed friend")
        } else if containsAny(title, ["kahve", "coffee", "çay", "tea"]) {
            specific = item("drink", "Kahve arkadaşım", "My coffee person")
        } else if containsAny(title, ["pizza", "makarna", "pasta", "tatlı", "dessert", "çikolata", "chocolate", "yemek", "food"]) {
            specific = item("food", "Birlikte yiyeceğim kişi", "The person I'd share a bite with")
        } else if containsAny(title, ["kedi", "cat", "köpek", "dog", "hayvan", "animal", "panda", "penguen", "penguin"]) {
            specific = item("animal", "Hayvan insanı", "The animal person")
        } else if containsAny(title, ["kitap", "book", "şiir", "poetry", "okuma", "reading"]) {
            specific = item("book", "Kitap kurdu", "The bookworm")
        } else if containsAny(title, ["müzik", "music", "caz", "jazz", "piyano", "piano", "radyo", "radio"]) {
            specific = item("music", "Playlist ustası", "The playlist expert")
        } else if containsAny(title, ["bilim", "science", "uzay", "space", "matematik", "math", "mühendis", "engineer"]) {
            specific = item("curious", "Meraklı arkadaşım", "My curious friend")
        } else if containsAny(title, ["film", "movie", "televizyon", "television", "video oyunu", "video game", "star wars"]) {
            specific = item("screen", "Ekran arkadaşım", "My screen-time friend")
        } else if containsAny(title, ["spor", "sport", "futbol", "football", "basketbol", "basketball", "bisiklet", "bicycle"]) {
            specific = item("team", "Takım arkadaşım", "My teammate")
        } else if containsAny(title, ["aile", "family", "ebeveyn", "parent", "kardeş", "sibling"]) {
            specific = item("family", "Aile grubu", "The family chat")
        } else {
            specific = item("first", "İlk aklıma gelen", "The first person I thought of")
        }

        let close = SharePersonalization(
            id: "close",
            label: language == "tr" ? "Yakın arkadaşım" : "A close friend",
            note: language == "tr" ? "Bunu görünce aklıma sen geldin." : "This made me think of you."
        )
        let noNote = SharePersonalization(
            id: "plain",
            label: language == "tr" ? "Sadece kart" : "Just the card",
            note: nil
        )
        return [specific, close, noNote]
    }

    private static func item(_ id: String, _ turkish: String, _ english: String) -> SharePersonalization {
        let language = DayEventStore.language
        return SharePersonalization(
            id: id,
            label: language == "tr" ? turkish : english,
            note: language == "tr" ? "Bugün resmen senin günün." : "Today is basically your day."
        )
    }

    private static func containsAny(_ value: String, _ terms: [String]) -> Bool {
        terms.contains(where: value.contains)
    }
}
