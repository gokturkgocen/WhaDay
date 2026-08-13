import Foundation

enum Strings {
    private static let bundle: Bundle = {
        guard
            let path = Bundle.main.path(forResource: DayEventStore.language, ofType: "lproj"),
            let bundle = Bundle(path: path)
        else {
            return .main
        }
        return bundle
    }()

    static var shareOnStory: String { localized("shareOnStory") }
    static var noEventTitle: String { localized("noEventTitle") }
    static var noEventDesc: String { localized("noEventDesc") }

    private static func localized(_ key: String) -> String {
        NSLocalizedString(key, bundle: bundle, comment: "")
    }
}
