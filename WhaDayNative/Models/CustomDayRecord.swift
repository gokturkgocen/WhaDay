import Foundation

struct CustomDayRecord: Codable, Identifiable, Equatable, Sendable {
    let id: String
    let month: Int
    let day: Int
    var title: String
    var description: String
    var emoji: String
    var authorName: String?
    let createdAt: Date
    var isImported: Bool

    init(
        id: String,
        month: Int,
        day: Int,
        title: String,
        description: String,
        emoji: String,
        authorName: String? = nil,
        createdAt: Date = Date(),
        isImported: Bool = false
    ) {
        self.id = id
        self.month = month
        self.day = day
        self.title = title
        self.description = description
        self.emoji = emoji
        self.authorName = authorName
        self.createdAt = createdAt
        self.isImported = isImported
    }

    /// Converts this custom record into a standard DayEvent for seamless rendering across all UI views.
    func toDayEvent() -> DayEvent {
        let meta = DayMetadata(
            id: id,
            authority: .cultural,
            category: .celebrations,
            sensitivity: .standard,
            shareability: 5,
            audience: ["personal"],
            symbol: "sparkles",
            reviewState: .curated,
            scope: nil,
            source: nil
        )
        let hook: String
        if let author = authorName, !author.trimmingCharacters(in: .whitespaces).isEmpty {
            hook = DayEventStore.language == "tr"
                ? "\(author) seninle bu özel günü paylaştı."
                : "\(author) shared this special occasion with you."
        } else {
            hook = DayEventStore.language == "tr"
                ? "Bugün senin için özel bir gün."
                : "Today is a special day for you."
        }

        return DayEvent(
            id: id,
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

    // MARK: - Compact Share Payload

    private struct CompactPayload: Codable {
        let id: String
        let m: Int
        let d: Int
        let t: String
        let desc: String
        let e: String
        let a: String?
    }

    /// Encodes the record into a compact URL-safe Base64 string.
    func toShareablePayload() -> String? {
        let compact = CompactPayload(
            id: id,
            m: month,
            d: day,
            t: title,
            desc: description,
            e: emoji,
            a: authorName
        )
        guard let data = try? JSONEncoder().encode(compact) else { return nil }
        return data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    /// Decodes a compact URL-safe Base64 string back into a CustomDayRecord.
    static func from(shareablePayload: String) -> CustomDayRecord? {
        var base64 = shareablePayload
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        while base64.count % 4 != 0 {
            base64.append("=")
        }

        guard
            let data = Data(base64Encoded: base64),
            let compact = try? JSONDecoder().decode(CompactPayload.self, from: data)
        else {
            return nil
        }

        return CustomDayRecord(
            id: compact.id,
            month: compact.m,
            day: compact.d,
            title: compact.t,
            description: compact.desc,
            emoji: compact.e,
            authorName: compact.a,
            createdAt: Date(),
            isImported: true
        )
    }

    /// Generates the universal web share link (which redirects into the app).
    func webShareURL() -> URL? {
        guard let payload = toShareablePayload() else { return nil }
        return URL(string: "https://gokturkgocen.github.io/WhaDay/c/?d=\(payload)")
    }

    /// Generates the direct custom scheme URL (whaday://custom?d=...).
    func customSchemeURL() -> URL? {
        guard let payload = toShareablePayload() else { return nil }
        return URL(string: "whaday://custom?d=\(payload)")
    }
}
