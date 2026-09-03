import SwiftUI
import UIKit

private enum Screen {
    case home, calendar, settings
}

struct RootView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var personalLibrary = PersonalDayLibrary()
    @StateObject private var customDayStore = CustomDayStore.shared
    @StateObject private var capsuleCloudManager = CapsuleCloudManager.shared
    @StateObject private var routeCenter = AppRouteCenter.shared
    @StateObject private var dateContext = AppDateContext()
    @StateObject private var reminderPreferences = ReminderPreferences()
    @StateObject private var purchaseStore = PurchaseStore()
    @State private var screen: Screen = .home
    @State private var selectedDay: DayEvent?
    @State private var shareEvent: DayEvent?
    @State private var incomingCustomDay: CustomDayRecord?

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
        .environmentObject(customDayStore)
        .environmentObject(capsuleCloudManager)
        .environmentObject(dateContext)
        .environmentObject(reminderPreferences)
        .environmentObject(purchaseStore)
        .task {
            Haptics.prepare()
            await NotificationScheduler.scheduleIfNeeded(configuration: reminderConfiguration)
        }
        .task {
            await monitorDayBoundaries()
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
        .sheet(item: $incomingCustomDay) { record in
            CustomDayImportSheet(record: record) { event in
                selectedDay = event
                screen = .home
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(32)
        }
        .onChange(of: customDayStore.customDays) { _, _ in
            handleTemporalChange()
        }
        .onChange(of: routeCenter.request?.id, initial: true) { _, _ in
            handleRouteRequest()
        }
        .onChange(of: reminderConfiguration) { _, configuration in
            Task { await NotificationScheduler.scheduleIfNeeded(configuration: configuration) }
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            dateContext.refresh()
            Task { await NotificationScheduler.scheduleIfNeeded(configuration: reminderConfiguration) }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in
            handleTemporalChange()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name.NSSystemTimeZoneDidChange)) { _ in
            handleTemporalChange()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSLocale.currentLocaleDidChangeNotification)) { _ in
            handleTemporalChange()
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
            guard let event = customDayStore.effectiveEvent(for: id) ?? DayEventStore.event(id: id) else {
                routeCenter.consume(request.id)
                return
            }
            selectedDay = event
            screen = .home
            shareEvent = event
        case .incomingCustomDay(let record):
            incomingCustomDay = record
        }

        routeCenter.consume(request.id)
    }

    private func handleTemporalChange() {
        dateContext.refresh()
        WidgetDataWriter.save(event: customDayStore.effectiveEvent(for: dateContext.dayID))
        Task { await NotificationScheduler.scheduleIfNeeded(configuration: reminderConfiguration) }
    }

    private var reminderConfiguration: ReminderConfiguration {
        reminderPreferences.configuration(savedIDs: personalLibrary.savedIDs)
    }

    private func monitorDayBoundaries() async {
        while !Task.isCancelled {
            let now = Date()
            let calendar = Calendar.current
            guard let boundary = DayDateResolver.nextDayBoundary(after: now, calendar: calendar) else {
                return
            }

            do {
                try await Task.sleep(for: .seconds(max(1, boundary.timeIntervalSince(now))))
            } catch {
                return
            }
            guard !Task.isCancelled else { return }
            handleTemporalChange()
        }
    }
}
