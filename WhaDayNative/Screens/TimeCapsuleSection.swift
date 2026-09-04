import SwiftUI

struct TimeCapsuleSection: View {
    @EnvironmentObject private var cloudManager: CapsuleCloudManager

    let capsuleID: String
    let targetMonth: Int
    let targetDay: Int
    let dayTitle: String
    let colors: ThemeColors

    @State private var showingNewNoteSheet: Bool = false

    private var notes: [CapsuleNote] {
        cloudManager.notes(for: capsuleID)
    }

    private var isLocked: Bool {
        let calendar = Calendar.current
        let now = Date()
        let currentMonth = calendar.component(.month, from: now)
        let currentDay = calendar.component(.day, from: now)

        if currentMonth < targetMonth {
            return true
        } else if currentMonth == targetMonth {
            return currentDay < targetDay
        } else {
            return false
        }
    }

    private var formattedTargetDate: String {
        var comps = DateComponents()
        comps.month = targetMonth
        comps.day = targetDay
        let formatter = DateFormatter()
        formatter.locale = DayEventStore.dateLocale
        formatter.dateFormat = "d MMMM"
        let date = Calendar.current.date(from: comps) ?? Date()
        return formatter.string(from: date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Section Header
            HStack(spacing: 10) {
                Image(systemName: isLocked ? "lock.shield.fill" : "lock.open.fill")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color(hex: colors.accent))

                Text(DayEventStore.language == "tr" ? "ZAMAN KAPSÜLÜ" : "TIME CAPSULE")
                    .appFont(size: 12, weight: .black, relativeTo: .caption)
                    .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.6))
                    .tracking(1.2)

                Spacer()

                if isLocked {
                    Text(DayEventStore.language == "tr" ? "Mühürlü" : "Sealed")
                        .appFont(size: 11, weight: .bold, relativeTo: .caption2)
                        .foregroundStyle(Color(hex: colors.ink))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color(hex: colors.accent))
                        .clipShape(Rectangle())
                }
            }

            if isLocked {
                lockedView
            } else {
                unlockedView
            }

            // Button to write a note
            Button {
                Haptics.triggerLight()
                showingNewNoteSheet = true
            } label: {
                HStack {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 14, weight: .bold))
                    Text(DayEventStore.language == "tr" ? "Mühürlü Not Bırak 🔏" : "Leave Sealed Note 🔏")
                        .appFont(size: 13, weight: .black, relativeTo: .subheadline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(hex: colors.ink).opacity(0.06))
                .foregroundStyle(Color(hex: colors.onBackdrop))
                .clipShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: colors.backdropRaised).opacity(0.94))
        .clipShape(Rectangle())
        .overlay(
            Rectangle()
                .strokeBorder(Color(hex: colors.ink).opacity(0.12), lineWidth: 1)
        )
        .task {
            await cloudManager.fetchNotes(for: capsuleID)
        }
        .sheet(isPresented: $showingNewNoteSheet) {
            NewCapsuleNoteSheet(
                capsuleID: capsuleID,
                targetMonth: targetMonth,
                targetDay: targetDay,
                dayTitle: dayTitle,
                colors: colors
            )
            .presentationDetents([.large])
        }
    }

    private var lockedView: some View {
        VStack(alignment: .leading, spacing: 10) {
            if notes.isEmpty {
                Text(DayEventStore.language == "tr"
                     ? "Bu güne henüz mühürlü not bırakılmadı. İlk notu sen yaz, \(formattedTargetDate) günü açılsın!"
                     : "No sealed notes yet. Write the first note, it will unlock on \(formattedTargetDate)!")
                    .appFont(size: 13, weight: .medium, relativeTo: .footnote)
                    .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.7))
                    .lineSpacing(2)
            } else {
                Text(DayEventStore.language == "tr"
                     ? "🔒 \(notes.count) kişi mühürlü not bıraktı"
                     : "🔒 \(notes.count) sealed notes left")
                    .appFont(size: 15, weight: .bold, relativeTo: .headline)
                    .foregroundStyle(Color(hex: colors.ink))

                Text(DayEventStore.language == "tr"
                     ? "Notlar \(formattedTargetDate) 00:00'a kadar kimseye görünmez."
                     : "Notes will remain hidden until \(formattedTargetDate).")
                    .appFont(size: 12, weight: .medium, relativeTo: .caption)
                    .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.6))

                HStack(spacing: 6) {
                    ForEach(0..<min(notes.count, 8), id: \.self) { _ in
                        Text("✉️")
                            .font(.system(size: 18))
                    }
                }
                .padding(.top, 4)
            }
        }
    }

    private var unlockedView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(DayEventStore.language == "tr"
                 ? "🎉 Kapsül açıldı! İşte bırakılan notlar:"
                 : "🎉 Capsule opened! Here are the notes:")
                .appFont(size: 14, weight: .bold, relativeTo: .headline)
                .foregroundStyle(Color(hex: colors.ink))

            if notes.isEmpty {
                Text(DayEventStore.language == "tr"
                     ? "Bu güne hiç not bırakılmamıştı. Şimdi bir anı ekleyebilirsin."
                     : "No notes were left for this day. You can add a memory now.")
                    .appFont(size: 13, weight: .medium, relativeTo: .footnote)
                    .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.7))
            } else {
                ForEach(notes) { note in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(note.authorName)
                                .appFont(size: 13, weight: .black, relativeTo: .caption)
                                .foregroundStyle(Color(hex: colors.ink))

                            Spacer()

                            Text(note.createdAt.formatted(date: .abbreviated, time: .shortened))
                                .appFont(size: 11, weight: .semibold, relativeTo: .caption2)
                                .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.5))
                        }

                        Text(note.content)
                            .appFont(size: 14, weight: .medium, relativeTo: .body)
                            .foregroundStyle(Color(hex: colors.ink).opacity(0.88))
                            .lineSpacing(2)
                    }
                    .padding(12)
                    .background(Color(hex: colors.ink).opacity(0.04))
                    .clipShape(Rectangle())
                }
            }
        }
    }
}
