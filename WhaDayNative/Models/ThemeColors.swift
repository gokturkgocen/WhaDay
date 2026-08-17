import SwiftUI

struct ThemeColors {
    let gradient: [String]
    let blob1: String
    let blob2: String
    let blob3: String
    let accent: String

    var paper: String { "#F2F0E8" }
    var ink: String { "#11110F" }
    var secondary: String { accent }
    var backdrop: String { "#090909" }
    var backdropRaised: String { "#171717" }
    var onBackdrop: String { "#F3F2ED" }

    // WhaDay stays neutral and editorial. Categories only change the restrained
    // signal colour; they never replace the product's black, paper and ink.
    static let byCategory: [String: ThemeColors] = [
        "wellness": palette("#8EAA9A"),
        "motivation": palette("#C6A15B"),
        "nature": palette("#829B77"),
        "awareness": palette("#8E9EBD"),
        "social": palette("#A18DAA"),
        "creative": palette("#B58D83"),
        "culture": palette("#B79B69"),
        "fun": palette("#7FA3B5"),
        "health": palette("#78A49B"),
        "lifestyle": palette("#B18A72"),
        "science": palette("#8297BA"),
        "tech": palette("#76A0A8"),
        "national": palette("#8496B5"),
        "action": palette("#B79A61"),
        "community": palette("#9A8AA7"),
        "diversity": palette("#A78C9F"),
        "growth": palette("#849B79"),
        "knowledge": palette("#7F94B3"),
        "mindfulness": palette("#8BA399"),
        "peace": palette("#879EAE"),
        "reflection": palette("#998DA8"),
        "sport": palette("#7898A8"),
        "default": palette("#929292"),
    ]

    private static func palette(_ accent: String) -> ThemeColors {
        ThemeColors(
            gradient: ["#F2F0E8", "#090909"],
            blob1: "#E7E4DB",
            blob2: accent,
            blob3: "#242424",
            accent: accent
        )
    }

    static func forCategory(_ category: String?) -> ThemeColors {
        byCategory[category ?? "default"] ?? byCategory["default"]!
    }

    static func forEvent(_ event: DayEvent?) -> ThemeColors {
        forCategory(event?.themeCategoryKey)
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
