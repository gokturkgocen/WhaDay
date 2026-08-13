import SwiftUI

private enum Screen {
    case home, calendar, settings
}

struct RootView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var screen: Screen = .home
    @State private var selectedDay: DayEvent?

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
                    eventCategory: selectedDay?.category,
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
        .task {
            Haptics.prepare()
            await NotificationScheduler.scheduleIfAuthorized()
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            Task { await NotificationScheduler.scheduleIfAuthorized() }
        }
    }
}
