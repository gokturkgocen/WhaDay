import SwiftUI
import UIKit
import UserNotifications

struct SettingsScreen: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var personalLibrary: PersonalDayLibrary
    @EnvironmentObject private var reminderPreferences: ReminderPreferences
    @EnvironmentObject private var purchaseStore: PurchaseStore

    let eventCategory: String?
    let onBack: () -> Void

    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined
    @State private var showingPlus = false
    private var colors: ThemeColors { ThemeColors.forCategory(eventCategory ?? "default") }

    var body: some View {
        ZStack {
            EditorialBackground(colors: colors, elapsed: 0)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header
                    editorialIntro
                    settingsSection
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 44)
            }
            .scrollIndicators(.hidden)
        }
        .task { notificationStatus = await NotificationScheduler.authorizationStatus() }
        .sheet(isPresented: $showingPlus) {
            PlusPaywallView(colors: colors)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(0)
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            Task {
                notificationStatus = await NotificationScheduler.authorizationStatus()
                await reschedule()
            }
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            BrandMark(color: Color(hex: colors.onBackdrop))
                .frame(width: 16, height: 16)
                .scaleEffect(0.34)

            Text("WHADAY")
                .appFont(size: 12, weight: .semibold, relativeTo: .caption)
                .tracking(2.2)

            Spacer()

            Button {
                Haptics.triggerLight()
                onBack()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.82))
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(DayEventStore.language == "tr" ? "Geri" : "Back")
            .accessibilityIdentifier("settings.back")
        }
        .padding(.top, 10)
        .foregroundStyle(Color(hex: colors.onBackdrop))
    }

    private var editorialIntro: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(DayEventStore.language == "tr" ? "WhaDay Hakkında" : "About WhaDay")
                .font(.system(size: 42, weight: .semibold, design: .serif))
                .tracking(-1.4)
                .foregroundStyle(Color(hex: colors.onBackdrop))
                .accessibilityAddTraits(.isHeader)
            Rectangle()
                .fill(Color(hex: colors.accent))
                .frame(width: 36, height: 2)
            Text(DayEventStore.language == "tr"
                 ? "WhaDay takvimdeki ilginç günleri, arkadaşlarınla paylaşabileceğin küçük anlara dönüştürür."
                 : "WhaDay turns curious calendar days into small moments worth sharing with friends.")
                .appFont(size: 16, weight: .semibold, relativeTo: .body)
                .lineSpacing(3)
                .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.68))
        }
        .padding(.top, 46)
        .padding(.bottom, 42)
    }

    private var reminderCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(DayEventStore.language == "tr" ? "Günün bahanesini kaçırma" : "Never miss today's excuse", systemImage: "bell.badge")
                .appFont(size: 17, weight: .black, relativeTo: .headline)
                .accessibilityAddTraits(.isHeader)

            Text(DayEventStore.language == "tr"
                 ? "Her sabah, o gün kime yazabileceğini hatırlatan tek bir kart."
                 : "One calm morning card with a reason to text someone that day.")
                .appFont(size: 14, weight: .semibold, relativeTo: .subheadline)
                .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.62))

            Toggle(isOn: reminderToggle) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(DayEventStore.language == "tr" ? "Günlük hatırlatıcı" : "Daily reminder")
                        .appFont(size: 15, weight: .black, relativeTo: .body)
                    Text(reminderStatusText)
                        .appFont(size: 11, weight: .semibold, relativeTo: .caption)
                        .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.56))
                }
            }
            .tint(Color(hex: colors.accent))

            if reminderPreferences.isEnabled {
                HStack {
                    Label(DayEventStore.language == "tr" ? "Hatırlatma saati" : "Reminder time", systemImage: "clock.fill")
                        .appFont(size: 13, weight: .black, relativeTo: .callout)
                    Spacer()
                    DatePicker("", selection: reminderTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .tint(Color(hex: colors.accent))
                        .accessibilityLabel(DayEventStore.language == "tr" ? "Hatırlatma saati" : "Reminder time")
                }
                .padding(.horizontal, 14)
                .frame(minHeight: 48)
                .background(Color.white.opacity(0.06))
                .clipShape(Rectangle())
            }

            if reminderPreferences.isEnabled && notificationStatus == .denied {
                Button {
                    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                    openURL(url)
                } label: {
                    Label(DayEventStore.language == "tr" ? "Sistem Ayarlarını aç" : "Open System Settings", systemImage: "gear")
                        .appFont(size: 13, weight: .black, relativeTo: .callout)
                        .foregroundStyle(Color(hex: colors.ink))
                        .padding(.horizontal, 16)
                        .frame(minHeight: 44)
                        .background(Color(hex: colors.accent))
                        .clipShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .foregroundStyle(Color(hex: colors.onBackdrop))
        .padding(.vertical, 24)
        .overlay(alignment: .top) { Divider().overlay(Color(hex: colors.onBackdrop).opacity(0.14)) }
    }

    private var plusCard: some View {
        Button {
            Haptics.triggerLight()
            showingPlus = true
        } label: {
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 7) {
                    Text("WHADAY+")
                        .appFont(size: 11, weight: .semibold, relativeTo: .caption)
                        .tracking(1.8)
                        .foregroundStyle(Color(hex: colors.accent))

                    Text(plusTitle)
                        .appFont(size: 19, weight: .semibold, relativeTo: .headline)
                        .foregroundStyle(Color(hex: colors.paper))

                    Text(plusSubtitle)
                        .appFont(size: 13, weight: .regular, relativeTo: .subheadline)
                        .lineSpacing(2)
                        .foregroundStyle(Color(hex: colors.paper).opacity(0.66))
                }

                Spacer(minLength: 12)

                Image(systemName: purchaseStore.isPlusUnlocked ? "checkmark" : "arrow.up.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(hex: colors.paper))
                    .frame(width: 38, height: 38)
                    .background(Color(hex: colors.paper).opacity(0.12))
                    .clipShape(Rectangle())
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.vertical, 24)
        .background(Color(hex: colors.onBackdrop))
        .clipShape(Rectangle())
        .accessibilityIdentifier("settings.plus")
    }

    private var plusTitle: String {
        if purchaseStore.isPlusUnlocked {
            return DayEventStore.language == "tr" ? "Plus etkin" : "Plus is active"
        }
        return DayEventStore.language == "tr" ? "Daha fazla görünüm" : "More ways to share"
    }

    private var plusSubtitle: String {
        if purchaseStore.isPlusUnlocked {
            return DayEventStore.language == "tr"
                ? "Grafit ve Ton görünümleri açık."
                : "Graphite and Tone appearances are unlocked."
        }
        let fallback = DayEventStore.language == "tr" ? "tek seferlik satın alma" : "one-time purchase"
        return DayEventStore.language == "tr"
            ? "Grafit ve Ton paylaşım görünümleri · \(purchaseStore.displayPrice ?? fallback)"
            : "Graphite and Tone share appearances · \(purchaseStore.displayPrice ?? fallback)"
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

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            plusCard
            reminderCard
            VStack(spacing: 14) {
            detailRow(icon: "globe", title: DayEventStore.language == "tr" ? "Dil" : "Language", value: DayEventStore.language == "tr" ? "Türkçe · Sistem dili" : "English · System language")
            Divider().overlay(Color(hex: colors.onBackdrop).opacity(0.14))
            detailRow(
                icon: "hand.raised",
                title: DayEventStore.language == "tr" ? "Gizlilik" : "Privacy",
                value: DayEventStore.language == "tr"
                    ? "Hesap yok · rehber erişimi yok"
                    : "No account · no contacts access"
            )
            Divider().overlay(Color(hex: colors.onBackdrop).opacity(0.14))
            detailRow(icon: "number", title: DayEventStore.language == "tr" ? "Sürüm" : "Version", value: "1.0")
            }
            .padding(.vertical, 24)
            .overlay(alignment: .top) { Divider().overlay(Color(hex: colors.onBackdrop).opacity(0.14)) }
        }
    }

    private func detailRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).appFont(size: 14, weight: .black, relativeTo: .body)
                Text(value).appFont(size: 12, weight: .semibold, relativeTo: .caption).opacity(0.62)
            }
            Spacer()
        }
        .foregroundStyle(Color(hex: colors.onBackdrop))
    }
}

private struct SettingsCardModifier: ViewModifier {
    let colors: ThemeColors

    func body(content: Content) -> some View {
        content
            .editorialSurface(colors: colors, emphasis: true, padding: 22)
    }
}

private extension View {
    func cardStyle(colors: ThemeColors) -> some View {
        modifier(SettingsCardModifier(colors: colors))
    }
}
