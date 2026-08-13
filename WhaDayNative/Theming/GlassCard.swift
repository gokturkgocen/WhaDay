import SwiftUI

struct GlassCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack {
            content()
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                Color.white.opacity(0.05)
                Color.black.opacity(0.2)
            }
        )
        .background(.thickMaterial.opacity(0.7))
        .environment(\.colorScheme, .dark)
        .overlay(
            VStack {
                Rectangle().fill(Color.white.opacity(0.2)).frame(height: 0.5)
                Spacer()
                Rectangle().fill(Color.black.opacity(0.4)).frame(height: 0.5)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .strokeBorder(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.5),
                            Color.white.opacity(0.2)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.25), radius: 20, x: 0, y: 8)
        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 20)
    }
}
