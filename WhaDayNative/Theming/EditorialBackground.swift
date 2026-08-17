import SwiftUI

struct EditorialBackground: View {
    let colors: ThemeColors
    let elapsed: TimeInterval

    var body: some View {
        Color(hex: colors.backdrop)
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

struct AmbientTimelineView<Content: View>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ViewBuilder let content: (TimeInterval) -> Content

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 15.0, paused: reduceMotion)) { context in
            content(context.date.timeIntervalSince(AmbientClock.epoch))
        }
    }
}
