import SwiftUI

struct BrandMark: View {
    let color: Color

    var body: some View {
        ZStack {
            Rectangle()
                .fill(color)
                .frame(width: 30, height: 2)
                .offset(y: -12)
            Rectangle()
                .fill(color)
                .frame(width: 2, height: 30)
                .offset(x: -12)
            Rectangle()
                .fill(color)
                .frame(width: 10, height: 10)
                .offset(x: 7, y: 7)
        }
        .frame(width: 42, height: 42)
        .accessibilityHidden(true)
    }
}
