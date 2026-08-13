import SwiftUI

struct HomeScreen: View {
    @Binding var selectedDay: DayEvent?
    let onOpenCalendar: () -> Void
    let onOpenSettings: () -> Void

    @AppStorage(BackgroundTheme.storageKey) private var backgroundTheme: BackgroundTheme = .classic
    @State private var activeID: String?
    @State private var shareImage: UIImage?
    @State private var appeared = false

    private let days = DayEventStore.days

    private var activeEvent: DayEvent? {
        days.first { $0.id == activeID }
    }

    private var themeColors: ThemeColors {
        ThemeColors.forCategory(activeEvent?.category)
    }

    var body: some View {
        ZStack {
            AmbientTimelineView { elapsed in
                BackgroundRenderer(theme: backgroundTheme, colors: themeColors, elapsed: elapsed)
                    .animation(.easeInOut(duration: 0.4), value: activeEvent?.category)
            }

            VStack(spacing: 0) {
                header
                dayPager
                ActionButtons(
                    primaryLabel: activeEvent?.sharingHook ?? Strings.shareOnStory,
                    secondaryLabel: Strings.shareOnStory,
                    shareImage: shareImage,
                    shareTitle: activeEvent?.title ?? "WhaDay",
                    accentColor: Color(hex: themeColors.accent)
                )
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 30)
        }
        .onAppear {
            if activeID == nil {
                activeID = (selectedDay ?? DayEventStore.today())?.id ?? days.first?.id
                syncSideEffects(for: activeEvent)
            }
            withAnimation(.easeOut(duration: 0.5)) { appeared = true }
        }
        .onChange(of: activeID) { _, _ in
            syncSideEffects(for: activeEvent)
        }
        .onChange(of: backgroundTheme) { _, _ in
            WidgetDataWriter.save(event: activeEvent, theme: backgroundTheme, colors: themeColors)
        }
    }

    private func syncSideEffects(for event: DayEvent?) {
        selectedDay = event
        WidgetDataWriter.save(event: event, theme: backgroundTheme, colors: ThemeColors.forCategory(event?.category))
        shareImage = ShareCardRenderer.render(event: event, colors: ThemeColors.forCategory(event?.category))
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text("WhaDay")
                    .font(.system(size: 36, weight: .black, design: .default))
                    .tracking(0.5)
                    .foregroundStyle(.white)
                if let event = activeEvent {
                    Text(formattedDate(for: event))
                        .font(.system(size: 14, weight: .semibold, design: .default))
                        .tracking(0.3)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }

            Spacer()

            HStack(spacing: 12) {
                headerButton { onOpenSettings() } content: {
                    Image(systemName: "gearshape.fill")
                        .foregroundStyle(.white.opacity(0.8))
                }
                headerButton { onOpenCalendar() } content: {
                    gridIcon
                }
            }
        }
        .padding(.horizontal, 28)
        .padding(.top, 70)
    }

    private func headerButton<Content: View>(action: @escaping () -> Void, @ViewBuilder content: () -> Content) -> some View {
        Button {
            Haptics.triggerLight()
            action()
        } label: {
            content()
                .frame(width: 44, height: 44)
                .background(Color.white.opacity(0.1))
                .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.white.opacity(0.2), lineWidth: 0.5))
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    private var gridIcon: some View {
        VStack(spacing: 3) {
            ForEach(0..<3, id: \.self) { _ in
                HStack(spacing: 3) {
                    ForEach(0..<3, id: \.self) { _ in
                        Circle().fill(Color.white.opacity(0.6)).frame(width: 4, height: 4)
                    }
                }
            }
        }
    }

    private var dayPager: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(days) { day in
                    dayPage(day)
                        .containerRelativeFrame(.horizontal)
                        .id(day.id)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $activeID)
        .scrollIndicators(.hidden)
    }

    private func dayPage(_ day: DayEvent) -> some View {
        VStack {
            Spacer()
            GlassCard {
                Text(day.emoji)
                    .font(.system(size: 76))
                    .padding(.bottom, 16)
                    .lineLimit(1)
                Text(day.title)
                    .font(.system(size: 28, weight: .bold, design: .default))
                    .tracking(-0.5)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .fixedSize(horizontal: false, vertical: true)
                Text(day.description)
                    .font(.system(size: 15, weight: .regular, design: .default))
                    .tracking(0.2)
                    .lineSpacing(1.5)
                    .foregroundStyle(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 12)
            }
            Spacer()
        }
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }

    private func formattedDate(for event: DayEvent) -> String {
        var components = DateComponents()
        components.year = Calendar.current.component(.year, from: Date())
        components.month = event.month
        components.day = event.day
        guard let date = Calendar.current.date(from: components) else { return "" }

        let formatter = DateFormatter()
        formatter.locale = DayEventStore.dateLocale
        formatter.setLocalizedDateFormatFromTemplate("EEEE MMMM d")
        return formatter.string(from: date)
    }
}
