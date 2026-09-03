import Combine
import Foundation

enum AppRoute: Equatable, Sendable {
    case home
    case day(id: String)
    case discovery
    case settings
    case share(id: String)
    case incomingCustomDay(CustomDayRecord)
    case incomingSpaceInvite(SharedSpace)

    static func parse(_ url: URL) -> AppRoute? {
        // Universal web links
        if url.scheme == "https" || url.scheme == "http" {
            if url.path.contains("/c"),
               let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let payload = components.queryItems?.first(where: { $0.name == "d" })?.value,
               let customDay = CustomDayRecord.from(shareablePayload: payload) {
                return .incomingCustomDay(customDay)
            }
            if url.path.contains("/s"),
               let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let payload = components.queryItems?.first(where: { $0.name == "d" })?.value,
               let space = SharedSpace.from(shareablePayload: payload) {
                return .incomingSpaceInvite(space)
            }
        }

        guard url.scheme?.lowercased() == "whaday" else { return nil }

        switch url.host?.lowercased() {
        case "home":
            return .home
        case "day":
            let id = url.pathComponents.dropFirst().first ?? ""
            guard isValidDayID(id) else { return nil }
            return .day(id: id)
        case "custom":
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let payload = components.queryItems?.first(where: { $0.name == "d" })?.value,
               let customDay = CustomDayRecord.from(shareablePayload: payload) {
                return .incomingCustomDay(customDay)
            }
            return nil
        case "space":
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let payload = components.queryItems?.first(where: { $0.name == "d" })?.value,
               let space = SharedSpace.from(shareablePayload: payload) {
                return .incomingSpaceInvite(space)
            }
            return nil
        case "calendar", "discover":
            return .discovery
        case "settings":
            return .settings
        case "share":
            let id = url.pathComponents.dropFirst().first ?? ""
            guard isValidDayID(id) else { return nil }
            return .share(id: id)
        default:
            return nil
        }
    }

    static func dayURL(id: String) -> URL? {
        guard isValidDayID(id) else { return nil }
        return URL(string: "whaday://day/\(id)")
    }

    static func shareURL(id: String) -> URL? {
        guard isValidDayID(id) else { return nil }
        return URL(string: "whaday://share/\(id)")
    }

    static func notificationRoute(userInfo: [AnyHashable: Any]) -> AppRoute? {
        guard let id = userInfo["dayId"] as? String, isValidDayID(id) else { return nil }
        return .day(id: id)
    }

    private static func isValidDayID(_ id: String) -> Bool {
        let components = id.split(separator: "-", omittingEmptySubsequences: false)
        guard
            components.count == 2,
            components[0].count == 2,
            components[1].count == 2,
            let month = Int(components[0]),
            let day = Int(components[1]),
            (1...12).contains(month),
            (1...31).contains(day)
        else {
            return false
        }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let referenceYear = month == 2 && day == 29 ? 2024 : 2025
        guard let date = calendar.date(from: DateComponents(year: referenceYear, month: month, day: day)) else {
            return false
        }
        let resolved = calendar.dateComponents([.month, .day], from: date)
        return resolved.month == month && resolved.day == day
    }
}

@MainActor
final class AppRouteCenter: ObservableObject {
    struct Request: Identifiable, Equatable {
        let id = UUID()
        let route: AppRoute
    }

    static let shared = AppRouteCenter()

    @Published private(set) var request: Request?

    init() {}

    func open(_ route: AppRoute) {
        request = Request(route: route)
    }

    func open(_ url: URL) {
        guard let route = AppRoute.parse(url) else { return }
        open(route)
    }

    func consume(_ requestID: UUID) {
        guard request?.id == requestID else { return }
        request = nil
    }
}
