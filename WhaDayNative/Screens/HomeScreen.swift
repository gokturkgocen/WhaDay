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
            AmbientTimelineView { elapsed in
                EditorialBackground(colors: themeColors, elapsed: elapsed)
                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.45), value: activeEvent?.category)
            }

            Group {
                if dynamicTypeSize.isAccessibilitySize {
                    accessibilityHome
                } else {
                    standardHome
                }
            }
            .opacity(reduceMotion || appeared ? 1 : 0)
            .offset(y: reduceMotion || appeared ? 0 : 18)

            if !hasCompletedCoach {
                FirstUseCoachView(
                    step: min(max(coachStep, 0), 2),
                    colors: themeColors,
                    onNext: advanceCoach,
                    onDismiss: completeCoach
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 92)
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
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.45)) { appeared = true }
        }
        .onChange(of: activeID) { _, _ in
            syncSideEffects(for: activeEvent)
        }
        .onChange(of: selectedDay?.id) { _, newID in
            guard let newID, newID != activeID else { return }
            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.28)) {
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
                .presentationCornerRadius(32)
        }
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
            withAnimation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.84)) {
                coachStep += 1
            }
        }
    }

    private func completeCoach() {
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.24)) {
            hasCompletedCoach = true
        }
    }

    private var standardHome: some View {
        VStack(spacing: 0) {
            header
            dayPager

            if let event = activeEvent {
                actionButtons(for: event)
            }
        }
    }

    private var accessibilityHome: some View {
        ScrollView {
            VStack(spacing: 12) {
                header

                if let event = activeEvent {
                    accessibilityDayNavigation(event)
                    dayPage(event)
                    actionButtons(for: event)
                }
            }
            .padding(.bottom, 20)
        }
        .scrollIndicators(.hidden)
    }

    private func actionButtons(for event: DayEvent) -> some View {
        ActionButtons(
            event: event,
            prompt: EditorialContent.forEvent(event).prompt,
            colors: themeColors
        )
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
        .appFont(size: 14, weight: .black, relativeTo: .headline)
        .foregroundStyle(Color(hex: themeColors.onBackdrop))
        .buttonStyle(.borderless)
        .padding(.horizontal, 24)
    }

    private var header: some View {
        HStack(spacing: 12) {
            HStack(spacing: 7) {
                BrandMark(color: Color(hex: themeColors.secondary))
                    .frame(width: 26, height: 26)
                    .scaleEffect(0.68)

                Text("WhaDay")
                    .appFont(size: 23, weight: .black, relativeTo: .title2)
                    .tracking(-0.8)
                    .lineLimit(1)
                    .minimumScaleFactor(0.58)
            }
            .foregroundStyle(Color(hex: themeColors.onBackdrop))

            Spacer()

            headerButton(systemName: "info", action: onOpenSettings)
            headerButton(systemName: "calendar", action: onOpenCalendar)
        }
        .padding(.horizontal, 22)
        .padding(.top, 10)
        .padding(.bottom, 8)
    }

    private func headerButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button {
            Haptics.triggerLight()
            action()
        } label: {
            Image(systemName: systemName)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color(hex: themeColors.onBackdrop))
                .frame(width: 42, height: 42)
                .background(Color.white.opacity(0.08))
                .clipShape(Circle())
                .overlay(Circle().strokeBorder(Color.white.opacity(0.13), lineWidth: 1))
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

        return VStack(spacing: 12) {
            HStack {
                Text((dynamicTypeSize.isAccessibilitySize ? formattedCompactDate(for: day) : formattedDate(for: day)).uppercased())
                    .appFont(size: 12, weight: .black, relativeTo: .caption)
                    .tracking(1.2)

                Spacer()

                if !dynamicTypeSize.isAccessibilitySize {
                    Text(dayPosition(day))
                        .appFont(size: 12, weight: .bold, design: .monospaced, relativeTo: .caption)
                }
            }
            .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.58))
            .padding(.horizontal, 28)

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    Text(dynamicTypeSize.isAccessibilitySize ? accessibleEyebrow(for: editorial) : editorial.eyebrow)
                        .appFont(size: 11, weight: .black, relativeTo: .caption)
                        .tracking(1.5)
                        .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(hex: colors.ink).opacity(0.88))
                        .foregroundStyle(Color(hex: colors.onBackdrop))
                        .clipShape(Capsule())

                    Spacer()

                    Text(EditorialSymbol.forEvent(day))
                        .font(.system(size: 42))
                        .frame(width: 74, height: 74)
                        .background(Color(hex: colors.secondary).opacity(0.9))
                        .clipShape(Circle())
                        .overlay(Circle().strokeBorder(Color(hex: colors.ink).opacity(0.18), lineWidth: 1))
                        .rotationEffect(.degrees(5))
                }

                Spacer(minLength: 12)

                Text(day.title)
                    .appFont(
                        size: dynamicTypeSize.isAccessibilitySize ? 22 : titleSize(for: day.title),
                        weight: .black,
                        relativeTo: .largeTitle
                    )
                    .tracking(-1.5)
                    .foregroundStyle(Color(hex: colors.ink))
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 4)
                    .minimumScaleFactor(0.72)
                    .fixedSize(horizontal: false, vertical: true)

                Rectangle()
                    .fill(Color(hex: colors.ink))
                    .frame(height: 2)
                    .padding(.vertical, 18)

                Text(editorial.fact)
                    .appFont(size: 17, weight: .semibold, relativeTo: .body)
                    .lineSpacing(3)
                    .foregroundStyle(Color(hex: colors.ink).opacity(0.82))
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 4)
                    .minimumScaleFactor(0.86)

                Spacer(minLength: 16)

                Button {
                    Haptics.triggerLight()
                    contextEvent = day
                } label: {
                    HStack(spacing: 7) {
                        Image(systemName: DayProvenance.forEvent(day).isOfficial ? "checkmark.seal.fill" : "info.circle.fill")
                        Text(DayEventStore.language == "tr" ? "Neden bugün?" : "Why today?")
                    }
                    .appFont(size: 12, weight: .black, relativeTo: .caption)
                    .foregroundStyle(Color(hex: colors.ink).opacity(0.80))
                    .padding(.horizontal, 12)
                    .frame(minHeight: 44)
                    .background(Color(hex: colors.ink).opacity(0.10))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                Spacer(minLength: 12)

                HStack(spacing: 8) {
                    BrandMark(color: Color(hex: colors.accent))
                        .frame(width: 22, height: 22)
                        .scaleEffect(0.52)
                    Text(editorial.prompt)
                        .appFont(size: 13, weight: .black, relativeTo: .callout)
                        .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)
                }
                .foregroundStyle(Color(hex: colors.ink))
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(
                LinearGradient(
                    colors: [Color(hex: colors.paper), Color(hex: colors.blob1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.20), lineWidth: 1)
            )
            .shadow(color: Color(hex: colors.accent).opacity(0.22), radius: 28, x: 0, y: 16)
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
        .padding(.top, 4)
        .accessibilityElement(children: .contain)
    }

    private func titleSize(for title: String) -> CGFloat {
        if title.count > 78 { return 29 }
        if title.count > 52 { return 33 }
        if title.count > 34 { return 38 }
        return 44
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

    private func accessibleEyebrow(for editorial: EditorialContent) -> String {
        if editorial.tone == .remembrance {
            return DayEventStore.language == "tr" ? "NOT" : "NOTE"
        }
        return DayEventStore.language == "tr" ? "BUGÜN" : "TODAY"
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
}
