import SwiftUI

/// Day/night atmosphere: twinkling stars at night, drifting light rays during the day.
/// Day/night is resolved once per view lifetime from the local hour, matching the original
/// (it was never meant to flip live while the app is open).
struct AtmosphereBackground: View {
    let elapsed: TimeInterval
    private let isNight: Bool

    init(elapsed: TimeInterval) {
        self.elapsed = elapsed
        let hour = Calendar.current.component(.hour, from: Date())
        self.isNight = hour < 6 || hour > 19
    }

    private static let stars: [(x: Double, y: Double, size: Double, offsetP: Double)] = (0..<15).map { i in
        let d = Double(i)
        return (
            x: (sin(d * 3.14) * 0.5 + 0.5),
            y: (cos(d * 7.42) * 0.5 + 0.5) * 0.7,
            size: (sin(d * 5.91) * 0.5 + 0.5) * 2 + 1,
            offsetP: abs(cos(d * 2.33))
        )
    }

    private static let rays: [(angle: Double, period: TimeInterval, offsetP: Double)] = [
        (angle: -15, period: 18, offsetP: 0),
        (angle: 25, period: 15, offsetP: 0.35),
    ]

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height

            ZStack {
                (isNight ? Color.black : Color.white)
                    .opacity(isNight ? 0.6 : 0.1)

                if isNight {
                    ForEach(Array(Self.stars.enumerated()), id: \.offset) { _, star in
                        let opacity = 0.35 + 0.25 * AmbientClock.sine(elapsed, period: 4, phase: star.offsetP)
                        Circle()
                            .fill(Color.white)
                            .frame(width: star.size, height: star.size)
                            .position(x: star.x * width, y: star.y * height)
                            .opacity(opacity)
                    }
                } else {
                    ForEach(Array(Self.rays.enumerated()), id: \.offset) { _, ray in
                        let opacity = max(0, 0.06 - 0.06 * AmbientClock.cosine(elapsed, period: ray.period, phase: ray.offsetP))
                        RoundedRectangle(cornerRadius: 150)
                            .fill(Color.white)
                            .frame(width: 300, height: height * 1.5)
                            .rotationEffect(.degrees(ray.angle))
                            .position(x: width / 2, y: 0)
                            .opacity(opacity)
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }
}
