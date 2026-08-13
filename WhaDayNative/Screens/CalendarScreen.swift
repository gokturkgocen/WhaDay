import SwiftUI

struct CalendarScreen: View {
    let selectedDay: DayEvent?
    let onBack: () -> Void
    let onSelectDay: (DayEvent) -> Void

    private let days = DayEventStore.days
    private let todayMonth = Calendar.current.component(.month, from: Date())
    private let todayDay = Calendar.current.component(.day, from: Date())

    private var grouped: [(month: Int, events: [DayEvent])] {
        let dict = Dictionary(grouping: days, by: \.month)
        return dict.keys.sorted().map { (month: $0, events: dict[$0] ?? []) }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#0f0c29"), Color(hex: "#1a1640"), Color(hex: "#0f0c29")],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 28) {
                            ForEach(grouped, id: \.month) { group in
                                monthSection(group)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                    .onAppear {
                        let todayID = days.first { $0.month == todayMonth && $0.day == todayDay }?.id
                        if let todayID {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                proxy.scrollTo(todayID, anchor: .center)
                            }
                        }
                    }
                }
            }
        }
    }

    private var header: some View {
        HStack {
            Button { onBack() } label: {
                Text("←")
                    .font(.system(size: 20))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
            Spacer()
            Text(DayEventStore.language == "tr" ? "Takvim" : "Calendar")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)
            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .padding(.top, 70)
        .padding(.bottom, 16)
    }

    private func monthSection(_ group: (month: Int, events: [DayEvent])) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(monthName(group.month))
                .font(.system(size: 24, weight: .heavy))
                .foregroundStyle(.white.opacity(0.4))
                .tracking(1)
                .textCase(.uppercase)

            ForEach(group.events) { event in
                dayRow(event)
                    .id(event.id)
            }
        }
    }

    private func dayRow(_ event: DayEvent) -> some View {
        let isToday = event.month == todayMonth && event.day == todayDay
        let isSelected = selectedDay.map { $0.month == event.month && $0.day == event.day } ?? isToday
        let theme = ThemeColors.forCategory(event.category)

        return Button {
            onSelectDay(event)
        } label: {
            HStack(spacing: 12) {
                Text("\(event.day)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(Color(hex: theme.accent).opacity(0.19))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                HStack(spacing: 8) {
                    Text(event.emoji).font(.system(size: 22))
                    Text(event.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if isToday {
                    Text(DayEventStore.language == "tr" ? "Bugün" : "Today")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color(hex: theme.accent))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(14)
            .background(.thinMaterial)
            .environment(\.colorScheme, .dark)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(isSelected ? Color(hex: theme.accent) : Color.white.opacity(0.08), lineWidth: isSelected ? 1.5 : 1)
            )
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
