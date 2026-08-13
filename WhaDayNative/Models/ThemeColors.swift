import SwiftUI

struct ThemeColors {
    let gradient: [String]
    let blob1: String
    let blob2: String
    let blob3: String
    let accent: String

    var paper: String { gradient[0] }
    var ink: String { "#111218" }
    var secondary: String { blob2 }
    var backdrop: String { "#0B0D12" }
    var backdropRaised: String { "#171A22" }
    var onBackdrop: String { "#F4F2EA" }

    // A nocturnal palette: the interface stays calm and dark while each day
    // gets one vivid, highly shareable colour pairing.
    static let byCategory: [String: ThemeColors] = [
        "wellness": palette("#9BE8C0", "#4FC98C", "#D9FF66", "#145C45", "#65D69E"),
        "motivation": palette("#FFE36A", "#FF9F43", "#FF7A45", "#744313", "#FFBE3D"),
        "nature": palette("#B9EA76", "#63C68A", "#E5FF9B", "#245B3C", "#78D46E"),
        "awareness": palette("#AFA8FF", "#766BFF", "#8DE7FF", "#37316F", "#8F86FF"),
        "social": palette("#C5A7FF", "#8E68F8", "#FF9ED6", "#49356E", "#A77CFF"),
        "creative": palette("#FF9BD2", "#FF6AAE", "#FFD166", "#7A2856", "#FF75B9"),
        "culture": palette("#FFC857", "#F29D49", "#FFED9A", "#6D4515", "#FFB13D"),
        "fun": palette("#75DBFF", "#4D8DFF", "#C5FF5A", "#224C75", "#59BEFF"),
        "health": palette("#7FE5D1", "#3CBFA9", "#B8FFEA", "#155E55", "#49CEB5"),
        "lifestyle": palette("#FFB067", "#FF7657", "#FFE16A", "#753C25", "#FF8D58"),
        "science": palette("#8BB8FF", "#5E74FF", "#7FF0FF", "#2A3F79", "#668CFF"),
        "tech": palette("#7DE3F0", "#4B9CFF", "#AEFFCB", "#205A6A", "#55C6E2"),
        "national": palette("#8FB6FF", "#5A72E8", "#FFE36A", "#2A3B72", "#6E8DF4"),
        "action": palette("#FFE36A", "#FF9F43", "#FF7A45", "#744313", "#FFBE3D"),
        "community": palette("#C5A7FF", "#8E68F8", "#8DE7FF", "#49356E", "#A77CFF"),
        "diversity": palette("#FF9BD2", "#8F86FF", "#FFE36A", "#63336C", "#CA7DFF"),
        "growth": palette("#B9EA76", "#63C68A", "#E5FF9B", "#245B3C", "#78D46E"),
        "knowledge": palette("#8BB8FF", "#5E74FF", "#7FF0FF", "#2A3F79", "#668CFF"),
        "mindfulness": palette("#9BE8C0", "#4FC98C", "#D9FF66", "#145C45", "#65D69E"),
        "peace": palette("#91D9FF", "#718EFF", "#C5A7FF", "#2E4D75", "#6ABEFF"),
        "reflection": palette("#C1A6E8", "#8B69C6", "#8DE7FF", "#493666", "#A785D8"),
        "sport": palette("#75DBFF", "#4D8DFF", "#C5FF5A", "#224C75", "#59BEFF"),
        "default": palette("#B5A6FF", "#766BFF", "#D9FF66", "#37316F", "#8F86FF"),
    ]

    private static func palette(_ paper: String, _ blob1: String, _ blob2: String, _ blob3: String, _ accent: String) -> ThemeColors {
        ThemeColors(gradient: [paper, "#111218"], blob1: blob1, blob2: blob2, blob3: blob3, accent: accent)
    }

    static func forCategory(_ category: String?) -> ThemeColors {
        byCategory[category ?? "default"] ?? byCategory["default"]!
    }
}

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)

        let r, g, b: Double
        if cleaned.count == 6 {
            r = Double((value >> 16) & 0xff) / 255
            g = Double((value >> 8) & 0xff) / 255
            b = Double(value & 0xff) / 255
        } else {
            r = 1; g = 1; b = 1
        }

        self.init(red: r, green: g, blue: b)
    }
}
