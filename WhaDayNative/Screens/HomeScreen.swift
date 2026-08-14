import SwiftUI

struct HomeScreen: View {
    @Binding var selectedDay: DayEvent?
    let onOpenCalendar: () -> Void
    let onOpenSettings: () -> Void

    @State private var activeID: String?
    @State private var contextEvent: DayEvent?
    @State private var appeared = false

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
                    .animation(.easeInOut(duration: 0.45), value: activeEvent?.category)
            }

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
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 18)
        }
        .onAppear {
            if activeID == nil {
                activeID = (selectedDay ?? DayEventStore.today())?.id ?? days.first?.id
                syncSideEffects(for: activeEvent)
            }
            withAnimation(.easeOut(duration: 0.45)) { appeared = true }
        }
        .onChange(of: activeID) { _, _ in
            syncSideEffects(for: activeEvent)
        }
        .onChange(of: selectedDay?.id) { _, newID in
            guard let newID, newID != activeID else { return }
            withAnimation(.easeInOut(duration: 0.28)) {
                activeID = newID
            }
        }
        .task(id: activeID) {
            await refreshAtNextDayBoundary()
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

    private func refreshAtNextDayBoundary() async {
        let calendar = Calendar.current
        let now = Date()
        guard let nextDay = calendar.nextDate(
            after: now,
            matching: DateComponents(hour: 0, minute: 0, second: 1),
            matchingPolicy: .nextTime
        ) else {
            return
        }

        let previousTodayID = DayEventStore.today()?.id
        let delay = max(1, nextDay.timeIntervalSince(now))
        do {
            try await Task.sleep(for: .seconds(delay))
        } catch {
            return
        }
        guard !Task.isCancelled else { return }

        let components = calendar.dateComponents([.month, .day], from: Date())
        guard
            let month = components.month,
            let day = components.day,
            let newToday = DayEventStore.event(month: month, day: day)
        else {
            return
        }

        // Keep an intentionally browsed day in place. Follow midnight only when
        // the pager was showing the day that just ended.
        if activeID == previousTodayID {
            activeID = newToday.id
        }
        WidgetDataWriter.save(event: newToday)
    }

    private var header: some View {
        HStack(spacing: 12) {
            HStack(spacing: 7) {
                BrandMark(color: Color(hex: themeColors.secondary))
                    .frame(width: 26, height: 26)
                    .scaleEffect(0.68)

                Text("WhaDay")
                    .font(.system(size: 23, weight: .black, design: .rounded))
                    .tracking(-0.8)
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
                Text(formattedDate(for: day).uppercased())
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .tracking(1.2)

                Spacer()

                Text(dayPosition(day))
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
            }
            .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.58))
            .padding(.horizontal, 28)

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    Text(editorial.eyebrow)
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .tracking(1.5)
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
                    .font(.system(size: titleSize(for: day.title), weight: .black, design: .rounded))
                    .tracking(-1.5)
                    .foregroundStyle(Color(hex: colors.ink))
                    .lineLimit(4)
                    .minimumScaleFactor(0.72)
                    .fixedSize(horizontal: false, vertical: true)

                Rectangle()
                    .fill(Color(hex: colors.ink))
                    .frame(height: 2)
                    .padding(.vertical, 18)

                Text(editorial.fact)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .lineSpacing(3)
                    .foregroundStyle(Color(hex: colors.ink).opacity(0.82))
                    .lineLimit(4)
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
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(Color(hex: colors.ink).opacity(0.80))
                    .padding(.horizontal, 12)
                    .frame(height: 34)
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
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .lineLimit(2)
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
        components.year = Calendar.current.component(.year, from: Date())
        components.month = event.month
        components.day = event.day
        guard let date = Calendar.current.date(from: components) else { return "" }

        let formatter = DateFormatter()
        formatter.locale = DayEventStore.dateLocale
        formatter.setLocalizedDateFormatFromTemplate("d MMMM EEEE")
        return formatter.string(from: date)
    }
}
