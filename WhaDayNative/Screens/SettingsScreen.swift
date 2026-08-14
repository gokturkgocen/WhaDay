import SwiftUI
import UIKit
import UserNotifications

struct SettingsScreen: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var personalLibrary: PersonalDayLibrary
    @EnvironmentObject private var reminderPreferences: ReminderPreferences

    let eventCategory: String?
    let onBack: () -> Void

    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined
    private var colors: ThemeColors { ThemeColors.forCategory(eventCategory ?? "default") }

    var body: some View {
        ZStack {
            EditorialBackground(colors: colors, elapsed: 0)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    manifestoCard
                    reminderCard
                    detailsCard
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 36)
            }
            .scrollIndicators(.hidden)
        }
        .task { notificationStatus = await NotificationScheduler.authorizationStatus() }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            Task {
                notificationStatus = await NotificationScheduler.authorizationStatus()
                await reschedule()
            }
        }
    }

    private var header: some View {
        HStack {
            Button {
                Haptics.triggerLight()
                onBack()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(Color(hex: colors.onBackdrop))
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.07))
                    .clipShape(Circle())
                    .overlay(Circle().strokeBorder(Color.white.opacity(0.14), lineWidth: 1))
            }
            .buttonStyle(.plain)

            Spacer()

            Text(DayEventStore.language == "tr" ? "WhaDay Hakkında" : "About WhaDay")
                .font(.system(size: 21, weight: .black, design: .rounded))
                .foregroundStyle(Color(hex: colors.onBackdrop))

            Spacer()
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.top, 10)
    }

    private var manifestoCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            BrandMark(color: Color(hex: colors.secondary))
            Text(DayEventStore.language == "tr" ? "Her gün, birine yazmak için yeni bir bahane." : "Every day, a new reason to text someone.")
                .font(.system(size: 31, weight: .black, design: .rounded))
                .tracking(-1)
                .foregroundStyle(Color(hex: colors.onBackdrop))
            Text(DayEventStore.language == "tr"
                 ? "WhaDay takvimdeki ilginç günleri, arkadaşlarınla paylaşabileceğin küçük anlara dönüştürür."
                 : "WhaDay turns curious calendar days into small moments worth sharing with friends.")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .lineSpacing(3)
                .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.68))
        }
        .cardStyle(colors: colors)
    }

    private var reminderCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(DayEventStore.language == "tr" ? "Günün bahanesini kaçırma" : "Never miss today's excuse", systemImage: "bell.badge")
                .font(.system(size: 17, weight: .black, design: .rounded))

            Text(DayEventStore.language == "tr"
                 ? "Her sabah, o gün kime yazabileceğini hatırlatan tek bir kart."
                 : "One calm morning card with a reason to text someone that day.")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.62))

            Toggle(isOn: reminderToggle) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(DayEventStore.language == "tr" ? "Günlük hatırlatıcı" : "Daily reminder")
                        .font(.system(size: 15, weight: .black, design: .rounded))
                    Text(reminderStatusText)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.56))
                }
            }
            .tint(Color(hex: colors.accent))

            if reminderPreferences.isEnabled {
                HStack {
                    Label(DayEventStore.language == "tr" ? "Hatırlatma saati" : "Reminder time", systemImage: "clock.fill")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                    Spacer()
                    DatePicker("", selection: reminderTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .tint(Color(hex: colors.accent))
                }
                .padding(.horizontal, 14)
                .frame(minHeight: 48)
                .background(Color.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }

            if reminderPreferences.isEnabled && notificationStatus == .denied {
                Button {
                    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                    openURL(url)
                } label: {
                    Label(DayEventStore.language == "tr" ? "Sistem Ayarlarını aç" : "Open System Settings", systemImage: "gear")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(Color(hex: colors.ink))
                        .padding(.horizontal, 16)
                        .frame(height: 42)
                        .background(Color(hex: colors.accent))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .foregroundStyle(Color(hex: colors.onBackdrop))
        .cardStyle(colors: colors)
    }

    private var reminderToggle: Binding<Bool> {
        Binding(
            get: { reminderPreferences.isEnabled },
            set: { isEnabled in
                reminderPreferences.setEnabled(isEnabled)
                Task {
                    if isEnabled && notificationStatus == .notDetermined {
                        _ = await NotificationScheduler.requestPermission()
                        notificationStatus = await NotificationScheduler.authorizationStatus()
                    }
                    await reschedule()
                }
            }
        )
    }

    private var reminderTime: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(
                    from: DateComponents(
                        year: 2001,
                        month: 1,
                        day: 1,
                        hour: reminderPreferences.hour,
                        minute: reminderPreferences.minute
                    )
                ) ?? Date()
            },
            set: { date in
                let components = Calendar.current.dateComponents([.hour, .minute], from: date)
                reminderPreferences.setTime(hour: components.hour ?? 9, minute: components.minute ?? 0)
            }
        )
    }

    private var reminderStatusText: String {
        let tr = DayEventStore.language == "tr"
        guard reminderPreferences.isEnabled else { return tr ? "WhaDay içinde kapalı" : "Off in WhaDay" }
        switch notificationStatus {
        case .authorized, .provisional, .ephemeral:
            return tr ? "Açık · her gün tek bildirim" : "On · one notification each day"
        case .denied:
            return tr ? "İstek açık, sistem izni kapalı" : "Wanted here, blocked by iOS"
        case .notDetermined:
            return tr ? "Açınca iOS izin soracak" : "iOS will ask when enabled"
        @unknown default:
            return tr ? "Sistem durumu bilinmiyor" : "System status unavailable"
        }
    }

    private func reschedule() async {
        await NotificationScheduler.scheduleIfNeeded(
            configuration: reminderPreferences.configuration(savedIDs: personalLibrary.savedIDs)
        )
    }

    private var detailsCard: some View {
        VStack(spacing: 14) {
            detailRow(icon: "globe", title: DayEventStore.language == "tr" ? "Dil" : "Language", value: DayEventStore.language == "tr" ? "Türkçe · Sistem dili" : "English · System language")
            Divider().overlay(Color.white.opacity(0.10))
            detailRow(icon: "hand.raised", title: DayEventStore.language == "tr" ? "Gizlilik" : "Privacy", value: DayEventStore.language == "tr" ? "Takip yok · Veri toplama yok" : "No tracking · No data collection")
            Divider().overlay(Color.white.opacity(0.10))
            detailRow(icon: "number", title: DayEventStore.language == "tr" ? "Sürüm" : "Version", value: "1.0")
        }
        .cardStyle(colors: colors)
    }

    private func detailRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 14, weight: .black, design: .rounded))
                Text(value).font(.system(size: 12, weight: .semibold, design: .rounded)).opacity(0.62)
            }
            Spacer()
        }
        .foregroundStyle(Color(hex: colors.onBackdrop))
    }
}

private extension View {
    func cardStyle(colors: ThemeColors) -> some View {
        self
            .padding(22)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: colors.backdropRaised).opacity(0.92))
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.11), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.22), radius: 20, x: 0, y: 10)
    }
}
