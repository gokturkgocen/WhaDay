import SwiftUI
import UserNotifications

struct SettingsScreen: View {
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

            if notificationStatus == .authorized || notificationStatus == .provisional {
                Label(DayEventStore.language == "tr" ? "Bildirimler açık" : "Notifications are on", systemImage: "checkmark.circle.fill")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(Color(hex: colors.accent))
            } else if notificationStatus == .notDetermined {
                Button(DayEventStore.language == "tr" ? "Bildirimleri aç" : "Turn on notifications") {
                    Task {
                        if await NotificationScheduler.requestPermission() {
                            await NotificationScheduler.scheduleAll()
                        }
                        notificationStatus = await NotificationScheduler.authorizationStatus()
                    }
                }
                .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(Color(hex: colors.ink))
                .padding(.horizontal, 16)
                .frame(height: 42)
                .background(Color(hex: colors.accent))
                .clipShape(Capsule())
            } else {
                Text(DayEventStore.language == "tr" ? "Bildirimler sistem ayarlarından kapalı." : "Notifications are disabled in System Settings.")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.58))
            }
        }
        .foregroundStyle(Color(hex: colors.onBackdrop))
        .cardStyle(colors: colors)
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
