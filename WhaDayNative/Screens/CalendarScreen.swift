import SwiftUI

private enum CalendarItem: Identifiable {
    case month(Int)
    case event(DayEvent)

    var id: String {
        switch self {
        case .month(let month): return "month-\(month)"
        case .event(let event): return event.id
        }
    }
}

private enum CalendarMode {
    case discover
    case allDays
}

struct CalendarScreen: View {
    @EnvironmentObject private var personalLibrary: PersonalDayLibrary

    let selectedDay: DayEvent?
    let onBack: () -> Void
    let onSelectDay: (DayEvent) -> Void

    @State private var mode: CalendarMode = .discover
    @State private var scrollPosition: String?

    private let days = DayEventStore.days
    private let todayMonth = Calendar.current.component(.month, from: Date())
    private let todayDay = Calendar.current.component(.day, from: Date())
    private let baseColors = ThemeColors.forCategory("default")

    private var weeklyPicks: [WeeklyPick] { WeeklyPicks.make() }
    private var savedEvents: [DayEvent] { personalLibrary.savedEvents() }

    private var items: [CalendarItem] {
        let grouped = Dictionary(grouping: days, by: \.month)
        return grouped.keys.sorted().flatMap { month in
            [.month(month)] + (grouped[month] ?? []).map(CalendarItem.event)
        }
    }

    private var todayID: String? {
        days.first { $0.month == todayMonth && $0.day == todayDay }?.id
    }

    var body: some View {
        ZStack {
            EditorialBackground(colors: baseColors, elapsed: 0)

            VStack(spacing: 0) {
                header

                switch mode {
                case .discover:
                    discoveryView
                case .allDays:
                    allDaysView
                }
            }
        }
    }

    private var discoveryView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                weeklySection

                if !savedEvents.isEmpty {
                    savedSection
                }

                openCalendarButton
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
    }

    private var allDaysView: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 10) {
                ForEach(items) { item in
                    switch item {
                    case .month(let month):
                        monthHeader(month)
                            .padding(.top, month == 1 ? 0 : 22)
                    case .event(let event):
                        dayRow(event)
                    }
                }
            }
            .scrollTargetLayout()
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .scrollPosition(id: $scrollPosition, anchor: .center)
        .scrollIndicators(.hidden)
    }

    private var header: some View {
        HStack {
            circleButton(systemName: "chevron.left", action: onBack)
            Spacer()
            VStack(spacing: 2) {
                Text(headerEyebrow)
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .tracking(1.5)
                Text(headerTitle)
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .tracking(-0.8)
            }
            .foregroundStyle(Color(hex: baseColors.onBackdrop))
            Spacer()
            circleButton(systemName: mode == .discover ? "calendar" : "scope") {
                if mode == .discover {
                    showAllDays()
                } else {
                    withAnimation(.easeInOut(duration: 0.25)) { scrollPosition = todayID }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 20)
    }

    private var headerEyebrow: String {
        if mode == .discover {
            return DayEventStore.language == "tr" ? "BU HAFTA" : "THIS WEEK"
        }
        return DayEventStore.language == "tr" ? "TÜM GÜNLER" : "ALL DAYS"
    }

    private var headerTitle: String {
        if mode == .discover {
            return DayEventStore.language == "tr" ? "Keşfet" : "Discover"
        }
        return DayEventStore.language == "tr" ? "Takvim" : "Calendar"
    }

    private var weeklySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text(DayEventStore.language == "tr" ? "Bu hafta atmalıklar" : "Worth sending this week")
                    .font(.system(size: 27, weight: .black, design: .rounded))
                    .tracking(-0.7)
                    .foregroundStyle(Color(hex: baseColors.onBackdrop))

                Text(DayEventStore.language == "tr"
                     ? "Takvimin içinden, birini hatırlatma ihtimali en yüksek üç gün."
                     : "Three days from the calendar most likely to remind you of someone.")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .lineSpacing(3)
                    .foregroundStyle(Color(hex: baseColors.onBackdrop).opacity(0.58))
            }

            ForEach(weeklyPicks) { pick in
                featuredRow(pick)
            }
        }
    }

    private var savedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(DayEventStore.language == "tr" ? "Sonra göndereceklerim" : "Saved to send later", systemImage: "bookmark.fill")
                    .font(.system(size: 19, weight: .black, design: .rounded))
                Spacer()
                Text("\(savedEvents.count)")
                    .font(.system(size: 12, weight: .black, design: .monospaced))
                    .padding(.horizontal, 9)
                    .frame(height: 26)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Capsule())
            }
            .foregroundStyle(Color(hex: baseColors.onBackdrop))

            ForEach(savedEvents.prefix(5)) { event in
                savedRow(event)
            }
        }
    }

    private func featuredRow(_ pick: WeeklyPick) -> some View {
        let event = pick.event
        let colors = ThemeColors.forCategory(event.category)
        let editorial = EditorialContent.forEvent(event)

        return HStack(spacing: 10) {
            Button {
                Haptics.triggerLight()
                onSelectDay(event)
            } label: {
                HStack(spacing: 13) {
                    VStack(spacing: 2) {
                        Text(shortWeekday(pick.date).uppercased())
                            .font(.system(size: 9, weight: .black, design: .rounded))
                            .tracking(0.7)
                        Text("\(event.day)")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                    }
                    .foregroundStyle(Color(hex: colors.ink))
                    .frame(width: 54, height: 58)
                    .background(Color(hex: colors.secondary))
                    .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))

                    VStack(alignment: .leading, spacing: 5) {
                        Text(event.title)
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundStyle(Color(hex: colors.onBackdrop))
                            .lineLimit(2)

                        Text(editorial.prompt)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.56))
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.34))
                }
            }
            .buttonStyle(.plain)

            saveButton(event, colors: colors)
        }
        .padding(12)
        .background(Color(hex: colors.backdropRaised).opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color(hex: colors.accent).opacity(0.24), lineWidth: 1)
        )
    }

    private func savedRow(_ event: DayEvent) -> some View {
        let colors = ThemeColors.forCategory(event.category)

        return HStack(spacing: 10) {
            Button {
                Haptics.triggerLight()
                onSelectDay(event)
            } label: {
                HStack(spacing: 12) {
                    Text(EditorialSymbol.forEvent(event))
                        .font(.system(size: 22))
                        .frame(width: 42, height: 42)
                        .background(Color(hex: colors.secondary).opacity(0.90))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 3) {
                        Text(event.title)
                            .font(.system(size: 14, weight: .black, design: .rounded))
                            .lineLimit(1)
                        Text(savedDate(event))
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .opacity(0.52)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .foregroundStyle(Color(hex: colors.onBackdrop))
            }
            .buttonStyle(.plain)

            saveButton(event, colors: colors)
        }
        .padding(10)
        .background(Color(hex: colors.backdropRaised).opacity(0.82))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var openCalendarButton: some View {
        Button {
            showAllDays()
        } label: {
            HStack {
                Image(systemName: "calendar")
                Text(DayEventStore.language == "tr" ? "Tüm 366 günü aç" : "Open all 366 days")
                Spacer()
                Image(systemName: "arrow.right")
            }
            .font(.system(size: 15, weight: .black, design: .rounded))
            .foregroundStyle(Color(hex: baseColors.ink))
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity, minHeight: 54)
            .background(Color(hex: baseColors.accent))
            .clipShape(RoundedRectangle(cornerRadius: 19, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func dayRow(_ event: DayEvent) -> some View {
        let isToday = event.month == todayMonth && event.day == todayDay
        let isSelected = selectedDay.map { $0.id == event.id } ?? isToday
        let colors = ThemeColors.forCategory(event.category)

        return HStack(spacing: 10) {
            Button {
                Haptics.triggerLight()
                onSelectDay(event)
            } label: {
                HStack(spacing: 13) {
                    Text(String(format: "%02d", event.day))
                        .font(.system(size: 16, weight: .black, design: .monospaced))
                        .foregroundStyle(Color(hex: colors.ink))
                        .frame(width: 46, height: 46)
                        .background(Color(hex: colors.secondary))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                    Text(EditorialSymbol.forEvent(event))
                        .font(.system(size: 21))

                    Text(event.title)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: colors.onBackdrop))
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if isToday {
                        Text(DayEventStore.language == "tr" ? "BUGÜN" : "TODAY")
                            .font(.system(size: 9, weight: .black, design: .rounded))
                            .tracking(0.8)
                            .foregroundStyle(Color(hex: colors.ink))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(Color(hex: colors.accent))
                            .clipShape(Capsule())
                    }
                }
            }
            .buttonStyle(.plain)

            saveButton(event, colors: colors)
        }
        .padding(12)
        .background(Color(hex: colors.backdropRaised).opacity(0.94))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(isSelected ? Color(hex: colors.accent) : Color.white.opacity(0.10), lineWidth: isSelected ? 2 : 1)
        )
        .shadow(color: Color(hex: colors.accent).opacity(isSelected ? 0.18 : 0), radius: 16, x: 0, y: 8)
    }

    private func saveButton(_ event: DayEvent, colors: ThemeColors) -> some View {
        Button {
            Haptics.triggerMedium()
            personalLibrary.toggle(event)
        } label: {
            Image(systemName: personalLibrary.isSaved(event) ? "bookmark.fill" : "bookmark")
                .font(.system(size: 14, weight: .black))
                .foregroundStyle(personalLibrary.isSaved(event) ? Color(hex: colors.ink) : Color(hex: colors.onBackdrop))
                .frame(width: 40, height: 40)
                .background(personalLibrary.isSaved(event) ? Color(hex: colors.accent) : Color.white.opacity(0.07))
                .clipShape(Circle())
                .overlay(Circle().strokeBorder(Color.white.opacity(0.10), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(personalLibrary.isSaved(event)
                            ? (DayEventStore.language == "tr" ? "Kaydı kaldır" : "Remove saved day")
                            : (DayEventStore.language == "tr" ? "Sonra göndermek için kaydet" : "Save to send later"))
    }

    private func circleButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button {
            Haptics.triggerLight()
            action()
        } label: {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(Color(hex: baseColors.onBackdrop))
                .frame(width: 44, height: 44)
                .background(Color.white.opacity(0.07))
                .clipShape(Circle())
                .overlay(Circle().strokeBorder(Color.white.opacity(0.14), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func monthHeader(_ month: Int) -> some View {
        Text(monthName(month).uppercased())
            .font(.system(size: 22, weight: .black, design: .rounded))
            .tracking(1)
            .foregroundStyle(Color(hex: baseColors.onBackdrop))
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func showAllDays() {
        withAnimation(.easeInOut(duration: 0.25)) { mode = .allDays }
        DispatchQueue.main.async { scrollPosition = todayID }
    }

    private func shortWeekday(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = DayEventStore.dateLocale
        formatter.setLocalizedDateFormatFromTemplate("EEE")
        return formatter.string(from: date)
    }

    private func savedDate(_ event: DayEvent) -> String {
        var components = DateComponents()
        components.year = Calendar.current.component(.year, from: Date())
        components.month = event.month
        components.day = event.day
        guard let date = Calendar.current.date(from: components) else { return "" }
        let formatter = DateFormatter()
        formatter.locale = DayEventStore.dateLocale
        formatter.setLocalizedDateFormatFromTemplate("d MMMM")
        return formatter.string(from: date)
    }

    private func monthName(_ month: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = DayEventStore.dateLocale
        let symbols = formatter.standaloneMonthSymbols ?? []
        return symbols.indices.contains(month - 1) ? symbols[month - 1] : ""
    }
}
