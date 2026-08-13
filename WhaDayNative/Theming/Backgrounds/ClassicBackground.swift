import SwiftUI

/// Three slowly-pulsing blobs (the original "classic" background).
struct ClassicBackground: View {
    let elapsed: TimeInterval
    let blob1Color: Color
    let blob2Color: Color
    let blob3Color: Color

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height

            blob(color: blob1Color, size: 280, x: width - 160, y: -80, period: 8)
            blob(color: blob2Color, size: 200, x: -40, y: height - 280, period: 10)
            blob(color: blob3Color, size: 150, x: width - 190, y: height - 150, period: 7)
        }
        .allowsHitTesting(false)
    }

    private func blob(color: Color, size: CGFloat, x: CGFloat, y: CGFloat, period: TimeInterval) -> some View {
        let scale = 0.95 + AmbientClock.pingPong(elapsed, period: period) * (1.08 - 0.95)
        return Circle()
            .fill(color)
            .frame(width: size, height: size)
            .opacity(0.3)
            .scaleEffect(scale)
            .position(x: x + size / 2, y: y + size / 2)
    }
}
