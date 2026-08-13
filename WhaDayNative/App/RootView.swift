import SwiftUI

private enum Screen {
    case home, calendar, settings
}

struct RootView: View {
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
            if await NotificationScheduler.requestPermission() {
                await NotificationScheduler.scheduleAll()
            }
        }
    }
}
