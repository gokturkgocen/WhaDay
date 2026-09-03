import Foundation

struct SharedSpace: Identifiable, Codable, Equatable, Sendable {
    let id: String
    var title: String
    var emoji: String
    let creatorName: String
    var members: [String]
    let createdAt: Date

    init(
        id: String = UUID().uuidString,
        title: String,
        emoji: String,
        creatorName: String,
        members: [String] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.emoji = emoji
        self.creatorName = creatorName
        self.members = members.isEmpty ? [creatorName] : members
        self.createdAt = createdAt
    }

    // MARK: - Compact Invite Payload

    private struct CompactPayload: Codable {
        let id: String
        let t: String
        let e: String
        let c: String
    }

    /// Encodes the space into a compact URL-safe Base64 string for invitation links.
    func toShareablePayload() -> String? {
        let compact = CompactPayload(
            id: id,
            t: title,
            e: emoji,
            c: creatorName
        )
        guard let data = try? JSONEncoder().encode(compact) else { return nil }
        return data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    /// Decodes an invitation payload back into a SharedSpace template.
    static func from(shareablePayload: String) -> SharedSpace? {
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

        return SharedSpace(
            id: compact.id,
            title: compact.t,
            emoji: compact.e,
            creatorName: compact.c,
            members: [compact.c]
        )
    }

    /// Generates the universal web share link.
    func webInviteURL() -> URL? {
        guard let payload = toShareablePayload() else { return nil }
        return URL(string: "https://gokturkgocen.github.io/WhaDay/s/?d=\(payload)")
    }

    /// Generates the direct custom scheme URL (whaday://space?d=...).
    func customSchemeURL() -> URL? {
        guard let payload = toShareablePayload() else { return nil }
        return URL(string: "whaday://space?d=\(payload)")
    }
}
