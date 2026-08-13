import SwiftUI

/// Renders the gradient + selected animated theme for a given category's colors.
/// Takes `elapsed` from a single shared `TimelineView` hoisted by the caller — when multiple
/// instances are composited together (e.g. crossfading day cards), they all read the same
/// clock tick instead of each running its own.
struct BackgroundRenderer: View {
    let theme: BackgroundTheme
    let colors: ThemeColors
    let elapsed: TimeInterval

    var body: some View {
        ZStack {
            LinearGradient(
                colors: colors.gradient.map(Color.init(hex:)),
                startPoint: .top,
                endPoint: .bottom
            )

            switch theme {
            case .classic:
                ClassicBackground(
                    elapsed: elapsed,
                    blob1Color: Color(hex: colors.blob1),
                    blob2Color: Color(hex: colors.blob2),
                    blob3Color: Color(hex: colors.blob3)
                )
            case .aurora:
                AuroraBackground(
                    elapsed: elapsed,
                    blob1Color: Color(hex: colors.blob1),
                    blob2Color: Color(hex: colors.blob2),
                    blob3Color: Color(hex: colors.blob3)
                )
            case .grain:
                GrainBackground()
            case .topo:
                TopoBackground(elapsed: elapsed)
            case .atmosphere:
                AtmosphereBackground(elapsed: elapsed)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

/// Hoists the single shared ambient clock for a stack of (possibly several, crossfading)
/// `BackgroundRenderer` layers.
struct AmbientTimelineView<Content: View>: View {
    @ViewBuilder let content: (TimeInterval) -> Content

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: false)) { context in
            content(context.date.timeIntervalSince(AmbientClock.epoch))
        }
    }
}
