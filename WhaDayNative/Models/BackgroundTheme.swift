import Foundation

enum BackgroundTheme: String, CaseIterable, Identifiable {
    static let storageKey = "bgTheme"

    case classic
    case aurora
    case grain
    case topo
    case atmosphere

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .classic: return "Classic Blobs"
        case .aurora: return "Apple Aurora"
        case .grain: return "Cinematic Grain"
        case .topo: return "Topography"
        case .atmosphere: return "Time Atmosphere"
        }
    }

    var localizedDescription: String {
        switch self {
        case .classic: return "Şu anki: Yavaşça nefes alan 3 organik şekil."
        case .aurora: return "Akışkan ve pürüzsüz renk geçişleri."
        case .grain: return "Film greni ve derin, fiziksel bir doku."
        case .topo: return "Çok yavaş akan, minimalist yatay çizgiler."
        case .atmosphere: return "Gündüz ışık hüzmeleri, gece yıldız tozu."
        }
    }
}
