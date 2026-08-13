import SwiftUI

/// Dark overlay + tiled film-grain texture — static, no animation.
struct GrainBackground: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.opacity(0.6)

                Image("GrainTexture")
                    .resizable(resizingMode: .tile)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .opacity(0.15)
            }
        }
        .allowsHitTesting(false)
    }
}
