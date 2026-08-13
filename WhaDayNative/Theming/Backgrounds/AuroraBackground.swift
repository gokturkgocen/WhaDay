import SwiftUI

/// Three large, heavily-blurred blobs drifting in ping-pong loops for a soft aurora-glass look.
struct AuroraBackground: View {
    let elapsed: TimeInterval
    let blob1Color: Color
    let blob2Color: Color
    let blob3Color: Color

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height

            ZStack {
                movingBlob(color: blob1Color, size: width * 1.5,
                           startX: -width * 0.25, startY: -height * 0.2,
                           moveX: width * 0.3, moveY: height * 0.2, period: 12)
                movingBlob(color: blob2Color, size: width * 1.2,
                           startX: width * 0.1, startY: height * 0.4,
                           moveX: -width * 0.4, moveY: -height * 0.3, period: 15)
                movingBlob(color: blob3Color, size: width,
                           startX: -width * 0.2, startY: height * 0.6,
                           moveX: width * 0.5, moveY: -height * 0.1, period: 18)
            }
            .blur(radius: 70)
        }
        .allowsHitTesting(false)
    }

    private func movingBlob(
        color: Color, size: CGFloat, startX: CGFloat, startY: CGFloat,
        moveX: CGFloat, moveY: CGFloat, period: TimeInterval
    ) -> some View {
        let progress = AmbientClock.pingPong(elapsed, period: period)
        let dx = moveX * progress
        let dy = moveY * progress
        return Circle()
            .fill(color)
            .frame(width: size, height: size)
            .opacity(0.6)
            .position(x: startX + size / 2 + dx, y: startY + size / 2 + dy)
    }
}
