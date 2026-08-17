import SwiftUI

@MainActor
enum ShareCardRenderer {
    static func render(
        event: DayEvent?,
        colors: ThemeColors,
        format: ShareCardFormat,
        style: ShareCardStyle = .playful,
        personalNote: String? = nil,
        language: String = DayEventStore.language
    ) -> UIImage? {
        let renderer = ImageRenderer(
            content: ShareCardView(
                event: event,
                colors: colors,
                format: format,
                style: style,
                personalNote: personalNote,
                language: language
            )
        )
        renderer.scale = 3
        return renderer.uiImage
    }
}
