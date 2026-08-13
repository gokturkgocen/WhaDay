import SwiftUI

@MainActor
enum ShareCardRenderer {
    static func render(event: DayEvent?, colors: ThemeColors, format: ShareCardFormat) -> UIImage? {
        let renderer = ImageRenderer(content: ShareCardView(event: event, colors: colors, format: format))
        renderer.scale = 3
        return renderer.uiImage
    }
}
