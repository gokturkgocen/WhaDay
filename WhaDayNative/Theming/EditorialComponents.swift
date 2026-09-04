import SwiftUI

/// The shared visual grammar for WhaDay's dictionary-like interface.
/// Surfaces are separated by rules and contrast, never by floating rounded cards.
struct EditorialSectionLabel: View {
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Text(title.uppercased())
                .appFont(size: 10, weight: .semibold, design: .monospaced, relativeTo: .caption)
                .tracking(1.5)
            Rectangle()
                .fill(color.opacity(0.24))
                .frame(height: 1)
        }
        .foregroundStyle(color.opacity(0.58))
        .accessibilityElement(children: .combine)
    }
}

private struct EditorialSurfaceModifier: ViewModifier {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var contrast

    let colors: ThemeColors
    let emphasis: Bool
    let padding: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                Color(hex: colors.backdropRaised)
                    .opacity(reduceTransparency ? 1 : (emphasis ? 0.96 : 0.72))
            )
            .overlay(alignment: .leading) {
                Rectangle()
                    .fill(Color(hex: colors.accent))
                    .frame(width: emphasis ? 3 : 1)
            }
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(Color(hex: colors.ink).opacity(contrast == .increased ? 0.34 : 0.12))
                    .frame(height: contrast == .increased ? 2 : 1)
            }
    }
}

extension View {
    func editorialSurface(
        colors: ThemeColors,
        emphasis: Bool = false,
        padding: CGFloat = 18
    ) -> some View {
        modifier(EditorialSurfaceModifier(colors: colors, emphasis: emphasis, padding: padding))
    }

    func editorialSelection(isSelected: Bool, colors: ThemeColors) -> some View {
        self
            .background(isSelected ? Color(hex: colors.accent) : Color.clear)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(Color(hex: colors.ink).opacity(isSelected ? 0.9 : 0.16))
                    .frame(height: isSelected ? 2 : 1)
            }
    }
}
