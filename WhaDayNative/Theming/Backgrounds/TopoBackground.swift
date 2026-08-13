import SwiftUI

/// Abstract topography contour lines, gently swaying horizontally.
///
/// Ported from the original SVG path (5 hand-authored wavy curves). The RN version linearly
/// interpolated a raw sawtooth timer straight into a translateX range, which produced a visible
/// jump-cut every 40s — every other background avoided exactly this by wrapping its timer in a
/// trig ping-pong. This port uses the same ping-pong form so the sway is seamless.
struct TopoBackground: View {
    let elapsed: TimeInterval

    var body: some View {
        let offsetX = -500 * AmbientClock.pingPong(elapsed, period: 40)

        ZStack {
            Color.black.opacity(0.4)

            TopoLines()
                .stroke(Color.white.opacity(0.08), lineWidth: 1.5)
                .offset(x: offsetX)
        }
        .allowsHitTesting(false)
    }
}

private struct TopoLines: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let lines: [(start: CGPoint, points: [(control: CGPoint, end: CGPoint)])] = [
            (CGPoint(x: -100, y: 200), [
                (CGPoint(x: 150, y: 50), CGPoint(x: 400, y: 250)),
                (CGPoint(x: 650, y: 450), CGPoint(x: 900, y: 150)),
                (CGPoint(x: 1150, y: -150), CGPoint(x: 1400, y: 300)),
            ]),
            (CGPoint(x: -100, y: 300), [
                (CGPoint(x: 200, y: 100), CGPoint(x: 500, y: 350)),
                (CGPoint(x: 800, y: 600), CGPoint(x: 1000, y: 200)),
                (CGPoint(x: 1200, y: -200), CGPoint(x: 1500, y: 400)),
            ]),
            (CGPoint(x: -100, y: 400), [
                (CGPoint(x: 250, y: 150), CGPoint(x: 600, y: 450)),
                (CGPoint(x: 950, y: 750), CGPoint(x: 1100, y: 250)),
                (CGPoint(x: 1250, y: -250), CGPoint(x: 1600, y: 500)),
            ]),
            (CGPoint(x: -100, y: 500), [
                (CGPoint(x: 300, y: 200), CGPoint(x: 700, y: 550)),
                (CGPoint(x: 1100, y: 900), CGPoint(x: 1200, y: 300)),
                (CGPoint(x: 1300, y: -300), CGPoint(x: 1700, y: 600)),
            ]),
            (CGPoint(x: -100, y: 600), [
                (CGPoint(x: 350, y: 250), CGPoint(x: 800, y: 650)),
                (CGPoint(x: 1250, y: 1050), CGPoint(x: 1300, y: 350)),
                (CGPoint(x: 1350, y: -350), CGPoint(x: 1800, y: 700)),
            ]),
        ]

        for line in lines {
            path.move(to: line.start)
            for segment in line.points {
                path.addQuadCurve(to: segment.end, control: segment.control)
            }
        }

        return path
    }
}
