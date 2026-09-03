import SwiftUI

struct SharedSpaceDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var spaceManager: SharedSpaceManager

    let space: SharedSpace
    let colors: ThemeColors
    let onSelectEvent: ((DayEvent) -> Void)?

    @State private var showingAddEventSheet = false
    @State private var showingShareInvite = false
    @State private var inviteURL: URL?

    private var events: [SharedSpaceEvent] {
        spaceManager.events(for: space.id)
            .sorted { $0.daysRemaining() < $1.daysRemaining() }
    }

    var body: some View {
        ZStack {
            EditorialBackground(colors: colors, elapsed: 0)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    spaceHeroCard
                    eventsListSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 36)
            }
            .scrollIndicators(.hidden)
        }
        .task {
            await spaceManager.fetchEvents(for: space.id)
        }
        .sheet(isPresented: $showingAddEventSheet) {
            NewSharedEventSheet(
                spaceID: space.id,
                spaceTitle: space.title,
                colors: colors
            ) { _ in
                // Refreshed automatically
            }
            .presentationDetents([.large])
        }
        .sheet(isPresented: $showingShareInvite) {
            if let url = inviteURL {
                SpaceShareSheet(items: [
                    "\(space.emoji) '\(space.title)' ortak takvimimize katıl:\n\(url.absoluteString)"
                ])
                .presentationDetents([.medium, .large])
            }
        }
    }

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 15, weight: .bold))
                    .frame(width: 44, height: 44)
                    .background(Color(hex: colors.ink).opacity(0.06))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Spacer()

            Button {
                shareInvite()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 13, weight: .bold))
                    Text(DayEventStore.language == "tr" ? "Davet Et" : "Invite")
                        .appFont(size: 12, weight: .bold, relativeTo: .caption)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color(hex: colors.accent))
                .foregroundStyle(Color(hex: colors.ink))
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .foregroundStyle(Color(hex: colors.onBackdrop))
        .padding(.top, 8)
    }

    private var spaceHeroCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Text(space.emoji)
                    .font(.system(size: 40))

                VStack(alignment: .leading, spacing: 2) {
                    Text(space.title)
                        .appFont(size: 22, weight: .black, relativeTo: .title3)
                        .foregroundStyle(Color(hex: colors.ink))

                    Text(membersText)
                        .appFont(size: 12, weight: .medium, relativeTo: .caption)
                        .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.6))
                }

                Spacer()
            }

            HStack {
                Button {
                    Haptics.triggerLight()
                    showingAddEventSheet = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 14, weight: .bold))
                        Text(DayEventStore.language == "tr" ? "Yeni Ortak Gün Ekle" : "Add Shared Day")
                            .appFont(size: 13, weight: .black, relativeTo: .subheadline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(hex: colors.ink).opacity(0.06))
                    .foregroundStyle(Color(hex: colors.ink))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 4)
        }
        .padding(18)
        .background(Color(hex: colors.backdropRaised).opacity(0.94))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color(hex: colors.ink).opacity(0.12), lineWidth: 1)
        )
    }

    private var eventsListSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(DayEventStore.language == "tr" ? "ORTAK GÜNLERİNİZ" : "SHARED DAYS")
                .appFont(size: 12, weight: .black, relativeTo: .caption)
                .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.6))
                .tracking(1.2)

            if events.isEmpty {
                VStack(spacing: 10) {
                    Text("📅")
                        .font(.system(size: 36))
                    Text(DayEventStore.language == "tr"
                         ? "Henüz ortak bir gün eklenmedi. 'Yeni Ortak Gün Ekle' butonuyla ilk gününüzü ekleyin!"
                         : "No shared days yet. Add your first day together!")
                        .appFont(size: 13, weight: .medium, relativeTo: .footnote)
                        .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(Color(hex: colors.backdropRaised).opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            } else {
                ForEach(events) { ev in
                    Button {
                        Haptics.triggerLight()
                        onSelectEvent?(ev.toDayEvent(spaceTitle: space.title))
                        dismiss()
                    } label: {
                        HStack(spacing: 14) {
                            Text(ev.emoji)
                                .font(.system(size: 28))
                                .frame(width: 48, height: 48)
                                .background(Color(hex: colors.accent).opacity(0.3))
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 3) {
                                Text(ev.title)
                                    .appFont(size: 16, weight: .bold, relativeTo: .body)
                                    .foregroundStyle(Color(hex: colors.ink))

                                Text("\(ev.formattedDate) · \(ev.addedBy)")
                                    .appFont(size: 12, weight: .medium, relativeTo: .caption)
                                    .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.6))
                            }

                            Spacer()

                            // Countdown badge
                            let remaining = ev.daysRemaining()
                            Text(countdownText(remaining))
                                .appFont(size: 11, weight: .black, relativeTo: .caption2)
                                .foregroundStyle(remaining == 0 ? Color(hex: colors.ink) : Color(hex: colors.onBackdrop))
                                .padding(.horizontal, 9)
                                .padding(.vertical, 5)
                                .background(remaining == 0 ? Color(hex: colors.accent) : Color(hex: colors.ink).opacity(0.08))
                                .clipShape(Capsule())
                        }
                        .padding(14)
                        .background(Color(hex: colors.backdropRaised).opacity(0.94))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var membersText: String {
        if space.members.count <= 1 {
            return DayEventStore.language == "tr" ? "1 üye (\(space.creatorName))" : "1 member"
        }
        return "\(space.members.count) \(DayEventStore.language == "tr" ? "üye" : "members"): \(space.members.joined(separator: ", "))"
    }

    private func countdownText(_ days: Int) -> String {
        if days == 0 {
            return DayEventStore.language == "tr" ? "BUGÜN! 🎉" : "TODAY! 🎉"
        } else if days == 1 {
            return DayEventStore.language == "tr" ? "YARIN" : "TOMORROW"
        } else {
            return DayEventStore.language == "tr" ? "\(days) gün kaldı" : "\(days) days left"
        }
    }

    private func shareInvite() {
        inviteURL = space.webInviteURL()
        showingShareInvite = true
    }
}

private struct SpaceShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
