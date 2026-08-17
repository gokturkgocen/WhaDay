import SwiftUI

struct HomeScreen: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @EnvironmentObject private var dateContext: AppDateContext

    @Binding var selectedDay: DayEvent?
    let onOpenCalendar: () -> Void
    let onOpenSettings: () -> Void

    @State private var activeID: String?
    @State private var contextEvent: DayEvent?
    @State private var appeared = false
    @AppStorage("firstUseCoachStep") private var coachStep = 0
    @AppStorage("hasCompletedFirstUseCoach") private var hasCompletedCoach = false

    private let days = DayEventStore.days

    private var activeEvent: DayEvent? {
        days.first { $0.id == activeID }
    }

    private var themeColors: ThemeColors {
        ThemeColors.forEvent(activeEvent)
    }

    var body: some View {
        ZStack {
            EditorialBackground(colors: themeColors, elapsed: 0)

            Group {
                if dynamicTypeSize.isAccessibilitySize {
                    accessibilityHome
                } else {
                    standardHome
                }
            }
            .opacity(reduceMotion || appeared ? 1 : 0)
            .offset(y: reduceMotion || appeared ? 0 : 10)

            if !hasCompletedCoach {
                FirstUseCoachView(
                    step: min(max(coachStep, 0), 2),
                    colors: themeColors,
                    onNext: advanceCoach,
                    onDismiss: completeCoach
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 86)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .transition(reduceMotion ? .identity : .move(edge: .bottom).combined(with: .opacity))
                .zIndex(10)
            }
        }
        .onAppear {
            if activeID == nil {
                activeID = (selectedDay ?? DayEventStore.event(id: dateContext.dayID))?.id ?? days.first?.id
                syncSideEffects(for: activeEvent)
            }
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.32)) {
                appeared = true
            }
        }
        .onChange(of: activeID) { _, _ in
            syncSideEffects(for: activeEvent)
        }
        .onChange(of: selectedDay?.id) { _, newID in
            guard let newID, newID != activeID else { return }
            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.22)) {
                activeID = newID
            }
        }
        .onChange(of: dateContext.dayID) { previousID, newID in
            guard previousID != newID else { return }
            if activeID == previousID {
                activeID = newID
            }
            WidgetDataWriter.save(event: DayEventStore.event(id: newID))
        }
        .sheet(item: $contextEvent) { event in
            DayContextSheet(event: event, colors: ThemeColors.forEvent(event))
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(24)
        }
    }

    private var standardHome: some View {
        VStack(spacing: 0) {
            header
            dayPager

            if let event = activeEvent {
                ActionButtons(
                    event: event,
                    prompt: EditorialContent.forEvent(event).prompt,
                    colors: themeColors
                )
            }
        }
    }

    private var accessibilityHome: some View {
        ScrollView {
            VStack(spacing: 0) {
                header

                if let event = activeEvent {
                    accessibilityDayNavigation(event)
                    dayPage(event)
                    ActionButtons(
                        event: event,
                        prompt: EditorialContent.forEvent(event).prompt,
                        colors: themeColors
                    )
                }
            }
            .padding(.bottom, 16)
        }
        .scrollIndicators(.hidden)
    }

    private var header: some View {
        HStack(spacing: 10) {
            BrandMark(color: Color(hex: themeColors.onBackdrop))
                .frame(width: 16, height: 16)
                .scaleEffect(0.34)

            Text("WHADAY")
                .appFont(size: 12, weight: .semibold, relativeTo: .caption)
                .tracking(2.2)

            Spacer()

            headerButton(systemName: "info.circle", action: onOpenSettings)
            headerButton(systemName: "calendar", action: onOpenCalendar)
        }
        .foregroundStyle(Color(hex: themeColors.onBackdrop))
        .padding(.horizontal, 22)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private func headerButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button {
            Haptics.triggerLight()
            action()
        } label: {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color(hex: themeColors.onBackdrop).opacity(0.82))
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
        .minimumAccessibleTarget()
        .accessibilityLabel(headerButtonLabel(systemName))
        .accessibilityIdentifier("home.\(systemName == "calendar" ? "calendar" : "settings")")
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
        let editorial = EditorialContent.forEvent(day)
        let colors = ThemeColors.forEvent(day)

        return VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text((dynamicTypeSize.isAccessibilitySize ? formattedCompactDate(for: day) : formattedDate(for: day)).uppercased())
                    .appFont(size: 11, weight: .medium, relativeTo: .caption)
                    .tracking(1.5)

                Spacer()

                Text(dayPosition(day))
                    .appFont(size: 11, weight: .medium, design: .monospaced, relativeTo: .caption)
            }
            .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.48))

            Spacer(minLength: dynamicTypeSize.isAccessibilitySize ? 22 : 34)

            Rectangle()
                .fill(Color(hex: colors.accent))
                .frame(width: 36, height: 2)
                .accessibilityHidden(true)

            Text(day.title)
                .font(.system(
                    size: dynamicTypeSize.isAccessibilitySize ? 34 : titleSize(for: day.title),
                    weight: .semibold,
                    design: .serif
                ))
                .tracking(-1.35)
                .foregroundStyle(Color(hex: colors.onBackdrop))
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 4)
                .minimumScaleFactor(0.74)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 18)

            Text(editorial.fact)
                .appFont(size: 17, weight: .regular, relativeTo: .body)
                .lineSpacing(4)
                .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.67))
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 5)
                .minimumScaleFactor(0.86)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 20)

            Spacer(minLength: 22)

            Button {
                Haptics.triggerLight()
                contextEvent = day
            } label: {
                HStack(spacing: 8) {
                    Text(DayEventStore.language == "tr" ? "Neden bugün?" : "Why today?")
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 11, weight: .semibold))
                }
                .appFont(size: 13, weight: .semibold, relativeTo: .callout)
                .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.78))
                .frame(minHeight: 44)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 28)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .accessibilityElement(children: .contain)
    }

    private func accessibilityDayNavigation(_ event: DayEvent) -> some View {
        HStack {
            Button {
                moveDay(from: event, offset: -1)
            } label: {
                Label(DayEventStore.language == "tr" ? "Önceki" : "Previous", systemImage: "chevron.left")
                    .labelStyle(.iconOnly)
            }
            .accessibilityLabel(DayEventStore.language == "tr" ? "Önceki gün" : "Previous day")
            .minimumAccessibleTarget()

            Spacer()

            Button {
                moveDay(from: event, offset: 1)
            } label: {
                Label(DayEventStore.language == "tr" ? "Sonraki" : "Next", systemImage: "chevron.right")
                    .labelStyle(.iconOnly)
            }
            .accessibilityLabel(DayEventStore.language == "tr" ? "Sonraki gün" : "Next day")
            .minimumAccessibleTarget()
        }
        .appFont(size: 14, weight: .semibold, relativeTo: .headline)
        .foregroundStyle(Color(hex: themeColors.onBackdrop))
        .buttonStyle(.borderless)
        .padding(.horizontal, 24)
    }

    private func titleSize(for title: String) -> CGFloat {
        if title.count > 88 { return 34 }
        if title.count > 62 { return 39 }
        if title.count > 40 { return 44 }
        return 50
    }

    private func dayPosition(_ event: DayEvent) -> String {
        guard let index = days.firstIndex(of: event) else { return "" }
        return String(format: "%03d / %03d", index + 1, days.count)
    }

    private func formattedDate(for event: DayEvent) -> String {
        var components = DateComponents()
        components.year = dateContext.calendar.component(.year, from: dateContext.now)
        components.month = event.month
        components.day = event.day
        guard let date = dateContext.calendar.date(from: components) else { return "" }

        let formatter = DateFormatter()
        formatter.locale = DayEventStore.dateLocale
        formatter.setLocalizedDateFormatFromTemplate("d MMMM EEEE")
        return formatter.string(from: date)
    }

    private func formattedCompactDate(for event: DayEvent) -> String {
        var components = DateComponents()
        components.year = dateContext.calendar.component(.year, from: dateContext.now)
        components.month = event.month
        components.day = event.day
        guard let date = dateContext.calendar.date(from: components) else { return "" }

        let formatter = DateFormatter()
        formatter.locale = DayEventStore.dateLocale
        formatter.setLocalizedDateFormatFromTemplate("d MMM")
        return formatter.string(from: date)
    }

    private func headerButtonLabel(_ systemName: String) -> String {
        if systemName == "calendar" {
            return DayEventStore.language == "tr" ? "Takvimi aç" : "Open calendar"
        }
        return DayEventStore.language == "tr" ? "WhaDay hakkında ve ayarlar" : "About WhaDay and settings"
    }

    private func moveDay(from event: DayEvent, offset: Int) {
        guard let index = days.firstIndex(of: event) else { return }
        let newIndex = min(max(index + offset, days.startIndex), days.index(before: days.endIndex))
        activeID = days[newIndex].id
    }

    private func syncSideEffects(for event: DayEvent?) {
        selectedDay = event
        WidgetDataWriter.save(event: event)
    }

    private func advanceCoach() {
        Haptics.triggerLight()
        if coachStep >= 2 {
            completeCoach()
        } else {
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.22)) {
                coachStep += 1
            }
        }
    }

    private func completeCoach() {
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.20)) {
            hasCompletedCoach = true
        }
    }
}
