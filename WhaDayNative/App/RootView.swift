import SwiftUI

private enum Screen {
    case home, calendar, settings
}

struct RootView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var personalLibrary = PersonalDayLibrary()
    @StateObject private var routeCenter = AppRouteCenter.shared
    @State private var screen: Screen = .home
    @State private var selectedDay: DayEvent?
    @State private var shareEvent: DayEvent?

    var body: some View {
        Group {
            switch screen {
            case .calendar:
                CalendarScreen(
                    selectedDay: selectedDay,
                    onBack: { screen = .home },
                    onSelectDay: { event in
                        selectedDay = event
                        screen = .home
                    }
                )
            case .settings:
                SettingsScreen(
                    eventCategory: selectedDay?.themeCategoryKey,
                    onBack: { screen = .home }
                )
            case .home:
                HomeScreen(
                    selectedDay: $selectedDay,
                    onOpenCalendar: { screen = .calendar },
                    onOpenSettings: { screen = .settings }
                )
            }
        }
        .environmentObject(personalLibrary)
        .task {
            Haptics.prepare()
            await NotificationScheduler.scheduleIfAuthorized()
        }
        .onOpenURL { url in
            routeCenter.open(url)
        }
        .sheet(item: $shareEvent) { event in
            ShareStudioView(event: event, colors: ThemeColors.forEvent(event))
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
        }
        .onChange(of: routeCenter.request?.id, initial: true) { _, _ in
            handleRouteRequest()
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            Task { await NotificationScheduler.scheduleIfAuthorized() }
        }
    }

    private func handleRouteRequest() {
        guard let request = routeCenter.request else { return }

        switch request.route {
        case .home:
            screen = .home
        case .day(let id):
            guard let event = DayEventStore.event(id: id) else {
                routeCenter.consume(request.id)
                return
            }
            selectedDay = event
            screen = .home
        case .discovery:
            screen = .calendar
        case .settings:
            screen = .settings
        case .share(let id):
            guard let event = DayEventStore.event(id: id) else {
                routeCenter.consume(request.id)
                return
            }
            selectedDay = event
            screen = .home
            shareEvent = event
        }

        routeCenter.consume(request.id)
    }
}
