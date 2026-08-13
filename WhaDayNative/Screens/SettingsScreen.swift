import SwiftUI

struct SettingsScreen: View {
    let eventCategory: String?
    let onBack: () -> Void

    @AppStorage(BackgroundTheme.storageKey) private var backgroundTheme: BackgroundTheme = .classic

    private var themeColors: ThemeColors { ThemeColors.forCategory(eventCategory) }

    var body: some View {
        ZStack {
            AmbientTimelineView { elapsed in
                BackgroundRenderer(theme: backgroundTheme, colors: themeColors, elapsed: elapsed)
            }

            VStack(spacing: 0) {
                header

                ScrollView {
                    GlassCard {
                        Text("ARKA PLAN TEMASI")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.8))
                            .tracking(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 16)

                        ForEach(Array(BackgroundTheme.allCases.enumerated()), id: \.element) { index, theme in
                            themeRow(theme)
                            if index != BackgroundTheme.allCases.count - 1 {
                                Rectangle().fill(Color.white.opacity(0.15)).frame(height: 0.5)
                            }
                        }
                    }
                    .padding(.top, 16)
                }
            }
        }
    }

    private var header: some View {
        HStack {
            Button { onBack() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
            Spacer()
            Text(DayEventStore.language == "tr" ? "Ayarlar" : "Settings")
                .font(.system(size: 24, weight: .bold, design: .default))
                .tracking(0.5)
                .foregroundStyle(.white)
            Spacer()
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, 20)
        .padding(.top, 70)
        .padding(.bottom, 24)
    }

    private func themeRow(_ theme: BackgroundTheme) -> some View {
        let isSelected = backgroundTheme == theme
        return Button {
            backgroundTheme = theme
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(theme.displayName)
                        .font(.system(size: 18, weight: isSelected ? .bold : .semibold))
                        .foregroundStyle(isSelected ? .white : .white.opacity(0.7))
                    Text(theme.localizedDescription)
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.5))
                }
                Spacer()
                Circle()
                    .strokeBorder(isSelected ? Color(hex: themeColors.accent) : Color.white.opacity(0.3), lineWidth: 2)
                    .frame(width: 24, height: 24)
                    .overlay {
                        if isSelected {
                            Circle().fill(Color(hex: themeColors.accent)).frame(width: 12, height: 12)
                        }
                    }
            }
            .padding(.vertical, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
