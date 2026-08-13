import SwiftUI

struct BrandMark: View {
    let color: Color

    var body: some View {
        ZStack {
            ForEach(0..<6, id: \.self) { index in
                Capsule()
                    .fill(color)
                    .frame(width: 7, height: 26)
                    .offset(y: -10)
                    .rotationEffect(.degrees(Double(index) * 60))
            }
            Circle()
                .fill(color)
                .frame(width: 7, height: 7)
        }
        .frame(width: 42, height: 42)
        .accessibilityHidden(true)
    }
}
