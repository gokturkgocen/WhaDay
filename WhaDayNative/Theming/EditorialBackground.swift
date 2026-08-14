import SwiftUI

struct EditorialBackground: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var contrast

    let colors: ThemeColors
    let elapsed: TimeInterval

    var body: some View {
        GeometryReader { geometry in
            let drift = AmbientClock.pingPong(elapsed, period: 11)

            ZStack {
                LinearGradient(
                    colors: [Color(hex: colors.backdrop), Color(hex: colors.backdropRaised)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                if !reduceTransparency && contrast != .increased {
                    Circle()
                        .fill(Color(hex: colors.accent).opacity(0.36))
                        .frame(width: geometry.size.width * 1.05)
                        .blur(radius: 90)
                        .scaleEffect(0.94 + drift * 0.12)
                        .position(x: geometry.size.width * 0.86, y: geometry.size.height * 0.16)

                    Circle()
                        .fill(Color(hex: colors.secondary).opacity(0.18))
                        .frame(width: geometry.size.width * 0.78)
                        .blur(radius: 100)
                        .position(x: geometry.size.width * 0.05, y: geometry.size.height * 0.87)

                    grid(in: geometry.size)
                        .foregroundStyle(Color.white.opacity(0.045))
                }
            }
            .clipped()
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private func grid(in size: CGSize) -> some View {
        Canvas { context, _ in
            let spacing: CGFloat = 30
            for x in stride(from: 0, through: size.width, by: spacing) {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(path, with: .foreground, lineWidth: 0.5)
            }
            for y in stride(from: 0, through: size.height, by: spacing) {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(path, with: .foreground, lineWidth: 0.5)
            }
        }
        .mask(LinearGradient(colors: [.clear, .black, .clear], startPoint: .top, endPoint: .bottom))
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
