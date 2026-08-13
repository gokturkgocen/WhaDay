import SwiftUI

struct GlassCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack {
            content()
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial.opacity(0.9))
        .environment(\.colorScheme, .dark)
        .overlay(
            VStack {
                Rectangle().fill(Color.white.opacity(0.15)).frame(height: 1)
                Spacer()
                Rectangle().fill(Color.black.opacity(0.3)).frame(height: 1)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .strokeBorder(Color.white.opacity(0.4), lineWidth: 0.5)
        )
        .padding(.horizontal, 24)
    }
}
