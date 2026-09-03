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
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @EnvironmentObject private var personalLibrary: PersonalDayLibrary
    @EnvironmentObject private var customDayStore: CustomDayStore
    @EnvironmentObject private var spaceManager: SharedSpaceManager
    @EnvironmentObject private var dateContext: AppDateContext
    @EnvironmentObject private var purchaseStore: PurchaseStore

    let selectedDay: DayEvent?
    let onBack: () -> Void
    let onSelectDay: (DayEvent) -> Void

    @State private var mode: CalendarMode = .discover
    @State private var scrollPosition: String?
    @State private var searchText = ""
    @State private var activeFilter: DayDiscoveryFilter = .all
    @State private var showingCreateSpace = false
    @State private var showingTimeMachine = false
    @State private var selectedSpace: SharedSpace?
    @FocusState private var searchFocused: Bool

    private var days: [DayEvent] {
        let base = customDayStore.effectiveDays()
        let shared = spaceManager.allSharedDays()
        if shared.isEmpty { return base }
        var map = Dictionary(uniqueKeysWithValues: base.map { ($0.id, $0) })
        for s in shared { map[s.id] = s }
        return base.map { map[$0.id] ?? $0 }
    }
    private let baseColors = ThemeColors.forCategory("default")

    private var todayMonth: Int {
        dateContext.calendar.component(.month, from: dateContext.now)
    }

    private var todayDay: Int {
        dateContext.calendar.component(.day, from: dateContext.now)
    }

    private var weeklyPicks: [WeeklyPick] {
        WeeklyPicks.make(from: dateContext.now, calendar: dateContext.calendar)
    }
    private var savedEvents: [DayEvent] { personalLibrary.savedEvents() }

    private var visibleDays: [DayEvent] {
        DayDiscoveryQuery.apply(
            to: days,
            searchText: searchText,
            filter: activeFilter,
            savedIDs: personalLibrary.savedIDs,
            locale: DayEventStore.dateLocale
        )
    }

    private var items: [CalendarItem] {
        let grouped = Dictionary(grouping: visibleDays, by: \.month)
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
        .sheet(isPresented: $showingCreateSpace) {
            CreateSpaceSheet(colors: baseColors) { newSpace in
                selectedSpace = newSpace
            }
            .presentationDetents([.large])
        }
        .sheet(item: $selectedSpace) { space in
            SharedSpaceDetailView(space: space, colors: baseColors) { event in
                onSelectDay(event)
            }
        }
        .sheet(isPresented: $showingTimeMachine) {
            TimeMachineSheet(colors: baseColors) { event in
                onSelectDay(event)
            }
            .presentationDetents([.large])
        }
    }

    private var discoveryView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                sharedSpacesSection
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
        VStack(spacing: 12) {
            searchField
            filterBar

            ScrollView {
                if visibleDays.isEmpty {
                    emptyResults
                } else {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(items) { item in
                            switch item {
                            case .month(let month):
                                monthHeader(month)
                                    .padding(.top, month == visibleDays.first?.month ? 0 : 22)
                            case .event(let event):
                                dayRow(event)
                            }
                        }
                    }
                    .scrollTargetLayout()
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .scrollPosition(id: $scrollPosition, anchor: .center)
            .scrollDismissesKeyboard(.interactively)
            .scrollIndicators(.hidden)
        }
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color(hex: baseColors.onBackdrop).opacity(0.52))
            TextField(
                DayEventStore.language == "tr" ? "Günlerde ara" : "Search days",
                text: $searchText
            )
            .focused($searchFocused)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .appFont(size: 15, weight: .bold, relativeTo: .body)
            .foregroundStyle(Color(hex: baseColors.onBackdrop))

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    searchFocused = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color(hex: baseColors.onBackdrop).opacity(0.50))
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(DayEventStore.language == "tr" ? "Aramayı temizle" : "Clear search")
            }
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 50)
        .background(Color.white.opacity(reduceTransparency ? 0.14 : 0.07))
        .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 17).strokeBorder(Color.white.opacity(0.11), lineWidth: 1))
        .padding(.horizontal, 20)
    }

    private var filterBar: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(DayDiscoveryFilter.allCases) { filter in
                    Button {
                        Haptics.triggerLight()
                        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.20)) { activeFilter = filter }
                    } label: {
                        Label(
                            filter.title(language: DayEventStore.language),
                            systemImage: activeFilter == filter ? "checkmark.circle.fill" : filter.symbol
                        )
                            .appFont(size: 12, weight: .black, relativeTo: .callout)
                            .foregroundStyle(activeFilter == filter
                                             ? Color(hex: baseColors.ink)
                                             : Color(hex: baseColors.onBackdrop))
                            .padding(.horizontal, 14)
                            .frame(minHeight: 44)
                            .background(activeFilter == filter
                                        ? Color(hex: baseColors.accent)
                                        : Color.white.opacity(0.07))
                            .clipShape(Capsule())
                            .overlay(Capsule().strokeBorder(Color.white.opacity(0.10), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .accessibilityValue(activeFilter == filter ? AccessibilityCopy.selected : "")
                }
            }
            .padding(.horizontal, 20)
        }
        .scrollIndicators(.hidden)
    }

    private var emptyResults: some View {
        VStack(spacing: 12) {
            Image(systemName: activeFilter == .saved ? "bookmark.slash" : "magnifyingglass")
                .font(.system(size: 28, weight: .black))
            Text(DayEventStore.language == "tr" ? "Burada gün yok" : "No days here")
                .appFont(size: 20, weight: .black, relativeTo: .title2)
            Text(DayEventStore.language == "tr"
                 ? "Aramayı temizle veya başka bir filtre dene."
                 : "Clear the search or try another filter.")
                .appFont(size: 13, weight: .semibold, relativeTo: .body)
                .opacity(0.58)
        }
        .foregroundStyle(Color(hex: baseColors.onBackdrop))
        .frame(maxWidth: .infinity)
        .padding(.top, 70)
        .padding(.horizontal, 30)
    }

    private var header: some View {
        HStack {
            circleButton(systemName: "chevron.left", action: onBack)
            Spacer()
            VStack(spacing: 2) {
                Text(headerEyebrow)
                    .appFont(size: 11, weight: .black, relativeTo: .caption)
                    .tracking(1.5)
                Text(headerTitle)
                    .appFont(size: dynamicTypeSize.isAccessibilitySize ? 20 : 28, weight: .black, relativeTo: .title)
                    .tracking(-0.8)
            }
            .foregroundStyle(Color(hex: baseColors.onBackdrop))
            Spacer()
            circleButton(systemName: mode == .discover ? "calendar" : "scope") {
                if mode == .discover {
                    showAllDays()
                } else {
                    withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) { scrollPosition = todayID }
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

    private var sharedSpacesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color(hex: baseColors.accent))

                    Text(DayEventStore.language == "tr" ? "BİZİM TAKVİMİMİZ" : "OUR CALENDAR")
                        .appFont(size: 12, weight: .black, relativeTo: .caption)
                        .foregroundStyle(Color(hex: baseColors.onBackdrop).opacity(0.6))
                        .tracking(1.2)
                }

                Spacer()

                HStack(spacing: 8) {
                    Button {
                        Haptics.triggerLight()
                        showingTimeMachine = true
                    } label: {
                        HStack(spacing: 4) {
                            Text("🕰️")
                                .font(.system(size: 11))
                            Text(DayEventStore.language == "tr" ? "Zaman Makinesi" : "Memories")
                                .appFont(size: 11, weight: .bold, relativeTo: .caption2)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.white.opacity(0.1))
                        .foregroundStyle(Color(hex: baseColors.onBackdrop))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)

                    Button {
                        Haptics.triggerLight()
                        showingCreateSpace = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.system(size: 11, weight: .black))
                            Text(DayEventStore.language == "tr" ? "Yeni Alan" : "New Space")
                                .appFont(size: 11, weight: .bold, relativeTo: .caption2)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.white.opacity(0.1))
                        .foregroundStyle(Color(hex: baseColors.onBackdrop))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }

            if spaceManager.spaces.isEmpty {
                Button {
                    Haptics.triggerLight()
                    showingCreateSpace = true
                } label: {
                    HStack(spacing: 14) {
                        Text("❤️")
                            .font(.system(size: 32))
                            .frame(width: 52, height: 52)
                            .background(Color(hex: baseColors.accent).opacity(0.3))
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 3) {
                            Text(DayEventStore.language == "tr" ? "Ortak Takvim Başlat" : "Create Shared Space")
                                .appFont(size: 15, weight: .black, relativeTo: .headline)
                                .foregroundStyle(Color(hex: baseColors.onBackdrop))

                            Text(DayEventStore.language == "tr"
                                 ? "Çiftin veya yakın arkadaşınla özel günleri canlı paylaşın."
                                 : "Share special days and countdowns live.")
                                .appFont(size: 12, weight: .medium, relativeTo: .caption)
                                .foregroundStyle(Color(hex: baseColors.onBackdrop).opacity(0.6))
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color(hex: baseColors.onBackdrop).opacity(0.4))
                    }
                    .padding(14)
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .buttonStyle(.plain)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(spaceManager.spaces) { space in
                            Button {
                                Haptics.triggerLight()
                                selectedSpace = space
                            } label: {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack(spacing: 8) {
                                        Text(space.emoji)
                                            .font(.system(size: 24))

                                        Text(space.title)
                                            .appFont(size: 15, weight: .black, relativeTo: .headline)
                                            .foregroundStyle(Color(hex: baseColors.onBackdrop))
                                            .lineLimit(1)

                                        Spacer(minLength: 4)

                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundStyle(Color(hex: baseColors.onBackdrop).opacity(0.4))
                                    }

                                    // Next event in space if any
                                    let spaceEvents = spaceManager.events(for: space.id)
                                    if let next = spaceEvents.min(by: { $0.daysRemaining() < $1.daysRemaining() }) {
                                        let days = next.daysRemaining()
                                        HStack(spacing: 4) {
                                            Text(next.emoji)
                                                .font(.system(size: 12))
                                            Text("\(next.title) · \(days == 0 ? (DayEventStore.language == "tr" ? "Bugün!" : "Today!") : "\(days)g")")
                                                .appFont(size: 11, weight: .bold, relativeTo: .caption2)
                                                .foregroundStyle(Color(hex: baseColors.accent))
                                        }
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(Color(hex: baseColors.accent).opacity(0.18))
                                        .clipShape(Capsule())
                                    } else {
                                        Text(DayEventStore.language == "tr" ? "Henüz gün eklenmedi" : "No days yet")
                                            .appFont(size: 11, weight: .medium, relativeTo: .caption2)
                                            .foregroundStyle(Color(hex: baseColors.onBackdrop).opacity(0.5))
                                    }
                                }
                                .padding(14)
                                .frame(width: 220, alignment: .leading)
                                .background(Color.white.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private var weeklySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text(DayEventStore.language == "tr" ? "Birine ulaşmak için üç neden" : "Three reasons to reach out")
                    .font(.system(
                        size: dynamicTypeSize.isAccessibilitySize ? 30 : 38,
                        weight: .semibold,
                        design: .serif
                    ))
                    .tracking(-1.1)
                    .foregroundStyle(Color(hex: baseColors.onBackdrop))

                Text(DayEventStore.language == "tr"
                     ? "Takvimden seçildi. Birini hatırlatırsa, gönder."
                     : "Selected from the calendar. If it reminds you of someone, send it.")
                    .appFont(size: 15, weight: .regular, relativeTo: .body)
                    .lineSpacing(2)
                    .foregroundStyle(Color(hex: baseColors.onBackdrop).opacity(0.58))
            }

            Rectangle()
                .fill(Color(hex: baseColors.onBackdrop).opacity(0.14))
                .frame(height: 1)
                .padding(.vertical, 4)

            ForEach(weeklyPicks) { pick in
                featuredRow(pick)
            }
        }
    }

    private var savedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(DayEventStore.language == "tr" ? "Sonra göndereceklerim" : "Saved to send later", systemImage: "bookmark.fill")
                    .appFont(size: 19, weight: .black, relativeTo: .title3)
                Spacer()
                Text("\(savedEvents.count)")
                    .appFont(size: 12, weight: .black, design: .monospaced, relativeTo: .caption)
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
        let colors = ThemeColors.forEvent(event)
        let editorial = EditorialContent.forEvent(event)

        return HStack(spacing: 10) {
            Button {
                Haptics.triggerLight()
                onSelectDay(event)
            } label: {
                HStack(spacing: 13) {
                    Rectangle()
                        .fill(Color(hex: colors.accent))
                        .frame(width: 3, height: 54)
                        .clipShape(Capsule())

                    VStack(alignment: .leading, spacing: 1) {
                        Text(String(format: "%02d", event.day))
                            .font(.system(size: 24, weight: .semibold, design: .serif))
                        Text(shortWeekday(pick.date).uppercased())
                            .appFont(size: 9, weight: .bold, relativeTo: .caption2)
                            .tracking(1.1)
                    }
                    .foregroundStyle(Color(hex: colors.onBackdrop))
                    .frame(width: 54, alignment: .leading)

                    VStack(alignment: .leading, spacing: 5) {
                        Text(event.title)
                            .appFont(size: 17, weight: .semibold, relativeTo: .headline)
                            .foregroundStyle(Color(hex: colors.onBackdrop))
                            .lineLimit(2)

                        Text(editorial.prompt)
                            .appFont(size: 12, weight: .regular, relativeTo: .subheadline)
                            .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.56))
                            .lineLimit(dynamicTypeSize.isAccessibilitySize ? 3 : 1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.34))
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(shortWeekday(pick.date)), \(event.title). \(editorial.prompt)")

            saveButton(event, colors: colors)
        }
        .padding(.vertical, 13)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color(hex: colors.onBackdrop).opacity(0.12))
                .frame(height: 1)
        }
    }

    private func savedRow(_ event: DayEvent) -> some View {
        let colors = ThemeColors.forEvent(event)

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
                            .appFont(size: 14, weight: .black, relativeTo: .headline)
                            .lineLimit(dynamicTypeSize.isAccessibilitySize ? 3 : 1)
                        Text(savedDate(event))
                            .appFont(size: 11, weight: .bold, relativeTo: .caption)
                            .opacity(0.52)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .foregroundStyle(Color(hex: colors.onBackdrop))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(event.title), \(savedDate(event))")

            saveButton(event, colors: colors)
        }
        .padding(10)
        .background(Color(hex: colors.backdropRaised).opacity(reduceTransparency ? 1 : 0.82))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var openCalendarButton: some View {
        Button {
            showAllDays()
        } label: {
            HStack {
                Text(DayEventStore.language == "tr" ? "Takvimi aç" : "Open the calendar")
                Spacer()
                Text("366")
                    .appFont(size: 12, weight: .bold, design: .monospaced, relativeTo: .caption)
                    .opacity(0.55)
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 13, weight: .semibold))
            }
            .appFont(size: 15, weight: .semibold, relativeTo: .headline)
            .foregroundStyle(Color(hex: baseColors.onBackdrop))
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: 52)
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Color(hex: baseColors.onBackdrop).opacity(0.24), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }

    private func dayRow(_ event: DayEvent) -> some View {
        let isToday = event.month == todayMonth && event.day == todayDay
        let isSelected = selectedDay.map { $0.id == event.id } ?? isToday
        let colors = ThemeColors.forEvent(event)

        return HStack(spacing: 10) {
            Button {
                Haptics.triggerLight()
                onSelectDay(event)
            } label: {
                HStack(spacing: 13) {
                    Text(String(format: "%02d", event.day))
                        .appFont(size: 16, weight: .black, design: .monospaced, relativeTo: .headline)
                        .foregroundStyle(Color(hex: colors.ink))
                        .frame(width: 46, height: 46)
                        .background(Color(hex: colors.secondary))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                    Text(EditorialSymbol.forEvent(event))
                        .font(.system(size: 21))

                    Text(event.title)
                        .appFont(size: 15, weight: .bold, relativeTo: .body)
                        .foregroundStyle(Color(hex: colors.onBackdrop))
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if isToday {
                        Text(DayEventStore.language == "tr" ? "BUGÜN" : "TODAY")
                            .appFont(size: 9, weight: .black, relativeTo: .caption2)
                            .tracking(0.8)
                            .foregroundStyle(Color(hex: colors.ink))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(Color(hex: colors.accent))
                            .clipShape(Capsule())
                    }

                    if differentiateWithoutColor && isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color(hex: colors.accent))
                            .accessibilityLabel(AccessibilityCopy.selected)
                    }
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(event.day), \(event.title)" + (isToday ? ", \(DayEventStore.language == "tr" ? "bugün" : "today")" : ""))
            .accessibilityValue(isSelected ? AccessibilityCopy.selected : "")

            saveButton(event, colors: colors)
        }
        .padding(12)
        .background(Color(hex: colors.backdropRaised).opacity(reduceTransparency ? 1 : 0.94))
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
        .minimumAccessibleTarget()
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
        .accessibilityLabel(circleButtonLabel(systemName))
        .accessibilityIdentifier("calendar.\(systemName == "chevron.left" ? "back" : "action")")
    }

    private func monthHeader(_ month: Int) -> some View {
        Text(monthName(month).uppercased())
            .appFont(size: 22, weight: .black, relativeTo: .title2)
            .tracking(1)
            .foregroundStyle(Color(hex: baseColors.onBackdrop))
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func showAllDays() {
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) { mode = .allDays }
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
        components.year = dateContext.calendar.component(.year, from: dateContext.now)
        components.month = event.month
        components.day = event.day
        guard let date = dateContext.calendar.date(from: components) else { return "" }
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

    private func circleButtonLabel(_ systemName: String) -> String {
        if systemName == "chevron.left" {
            return DayEventStore.language == "tr" ? "Geri" : "Back"
        }
        if mode == .discover {
            return DayEventStore.language == "tr" ? "Tüm günleri aç" : "Open all days"
        }
        return DayEventStore.language == "tr" ? "Bugüne git" : "Go to today"
    }
}
