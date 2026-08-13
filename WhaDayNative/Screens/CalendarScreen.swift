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

struct CalendarScreen: View {
    let selectedDay: DayEvent?
    let onBack: () -> Void
    let onSelectDay: (DayEvent) -> Void

    @State private var scrollPosition: String?

    private let days = DayEventStore.days
    private let todayMonth = Calendar.current.component(.month, from: Date())
    private let todayDay = Calendar.current.component(.day, from: Date())
    private let baseColors = ThemeColors.forCategory("default")

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
                .onAppear {
                    DispatchQueue.main.async { scrollPosition = todayID }
                }
            }
        }
    }

    private var header: some View {
        HStack {
            circleButton(systemName: "chevron.left", action: onBack)
            Spacer()
            VStack(spacing: 2) {
                Text(DayEventStore.language == "tr" ? "TÜM GÜNLER" : "ALL DAYS")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .tracking(1.5)
                Text(DayEventStore.language == "tr" ? "Takvim" : "Calendar")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .tracking(-0.8)
            }
            .foregroundStyle(Color(hex: baseColors.onBackdrop))
            Spacer()
            circleButton(systemName: "scope", action: { scrollPosition = todayID })
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 20)
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

    private func dayRow(_ event: DayEvent) -> some View {
        let isToday = event.month == todayMonth && event.day == todayDay
        let isSelected = selectedDay.map { $0.id == event.id } ?? isToday
        let colors = ThemeColors.forCategory(event.category)

        return Button {
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
            .padding(12)
            .background(Color(hex: colors.backdropRaised).opacity(0.94))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(isSelected ? Color(hex: colors.accent) : Color.white.opacity(0.10), lineWidth: isSelected ? 2 : 1)
            )
            .shadow(color: Color(hex: colors.accent).opacity(isSelected ? 0.18 : 0), radius: 16, x: 0, y: 8)
        }
        .buttonStyle(.plain)
    }

    private func monthName(_ month: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = DayEventStore.dateLocale
        let symbols = formatter.standaloneMonthSymbols ?? []
        return symbols.indices.contains(month - 1) ? symbols[month - 1] : ""
    }
}
