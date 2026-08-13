import SwiftUI

@MainActor
enum ShareCardRenderer {
    static func render(event: DayEvent?, colors: ThemeColors) -> UIImage? {
        let renderer = ImageRenderer(content: ShareCardView(event: event, colors: colors))
        renderer.scale = 1
        return renderer.uiImage
    }
}
