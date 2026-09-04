import SwiftUI

struct TimeMachineSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var timeMachine: TimeMachineManager

    let colors: ThemeColors
    let onSelectDay: ((DayEvent) -> Void)?

    private var onThisDayMemories: [PastMemory] {
        timeMachine.memoriesOnThisDay()
    }

    var body: some View {
        ZStack {
            EditorialBackground(colors: colors, elapsed: 0)

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header

                    if !onThisDayMemories.isEmpty {
                        onThisDaySection
                    }

                    memoriesArchiveSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 36)
            }
            .scrollIndicators(.hidden)
        }
        .onAppear {
            timeMachine.refresh()
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text("🕰️")
                        .font(.system(size: 24))
                    Text(DayEventStore.language == "tr" ? "Zaman Makinesi" : "Time Machine")
                        .font(.system(size: 30, weight: .semibold, design: .serif))
                        .tracking(-0.6)
                }

                Text(DayEventStore.language == "tr"
                     ? "Geçmişte mühürlenip açılmış günler ve notlar."
                     : "Past unlocked days and sealed notes.")
                    .appFont(size: 13, weight: .bold, relativeTo: .subheadline)
                    .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.6))
            }

            Spacer()

            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .black))
                    .frame(width: 44, height: 44)
                    .background(Color(hex: colors.ink).opacity(0.06))
                    .clipShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .foregroundStyle(Color(hex: colors.onBackdrop))
        .padding(.top, 10)
    }

    private var onThisDaySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .foregroundStyle(Color(hex: colors.accent))
                Text(DayEventStore.language == "tr" ? "BUGÜNÜN NOSTALJİSİ" : "ON THIS DAY")
                    .appFont(size: 11, weight: .black, relativeTo: .caption)
                    .tracking(1.2)
                    .foregroundStyle(Color(hex: colors.accent))
            }

            ForEach(onThisDayMemories) { mem in
                onThisDayCard(mem)
            }
        }
    }

    private func onThisDayCard(_ mem: PastMemory) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Text(mem.emoji)
                    .font(.system(size: 32))
                VStack(alignment: .leading, spacing: 2) {
                    Text(mem.title)
                        .appFont(size: 17, weight: .bold, relativeTo: .headline)
                        .foregroundStyle(Color(hex: colors.ink))
                    Text(mem.formattedDate)
                        .appFont(size: 12, weight: .medium, relativeTo: .caption)
                        .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.6))
                }
            }

            if !mem.notes.isEmpty {
                Divider().background(Color(hex: colors.ink).opacity(0.1))
                ForEach(mem.notes) { note in
                    onThisDayNoteRow(note)
                }
            }
        }
        .padding(16)
        .background(Color(hex: colors.backdropRaised).opacity(0.96))
        .clipShape(Rectangle())
        .overlay(
            Rectangle()
                .strokeBorder(Color(hex: colors.accent), lineWidth: 1.5)
        )
    }

    private func onThisDayNoteRow(_ note: CapsuleNote) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(note.authorName.isEmpty ? "Arkadaşın" : note.authorName)
                    .appFont(size: 11, weight: .bold, relativeTo: .caption2)
                    .foregroundStyle(Color(hex: colors.accent))
                Spacer()
                Text(note.formattedTime)
                    .appFont(size: 10, weight: .medium, relativeTo: .caption2)
                    .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.5))
            }
            Text(note.content)
                .appFont(size: 13, weight: .medium, relativeTo: .body)
                .foregroundStyle(Color(hex: colors.ink))
        }
        .padding(10)
        .background(Color(hex: colors.ink).opacity(0.04))
        .clipShape(Rectangle())
    }

    private var memoriesArchiveSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(DayEventStore.language == "tr" ? "AÇILMIŞ KAPSÜLLER & ANILAR" : "MEMORY ARCHIVE")
                .appFont(size: 12, weight: .black, relativeTo: .caption)
                .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.6))
                .tracking(1.2)

            if timeMachine.memories.isEmpty {
                VStack(spacing: 12) {
                    Text("🕰️")
                        .font(.system(size: 38))
                    Text(DayEventStore.language == "tr"
                         ? "Henüz geçmiş bir anı bulunmuyor."
                         : "No past memories yet.")
                        .appFont(size: 15, weight: .bold, relativeTo: .headline)
                        .foregroundStyle(Color(hex: colors.ink))
                    Text(DayEventStore.language == "tr"
                         ? "Özel günleriniz geçtikçe ve mühürlü notların kilitleri açıldıkça tüm hatıralar burada birikir."
                         : "As special dates arrive and sealed notes unlock, your memories will be preserved here.")
                        .appFont(size: 12, weight: .medium, relativeTo: .footnote)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(28)
                .background(Color(hex: colors.backdropRaised).opacity(0.7))
                .clipShape(Rectangle())
            } else {
                ForEach(timeMachine.memories) { mem in
                    memoryCard(mem)
                }
            }
        }
    }

    private func memoryCard(_ mem: PastMemory) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Text(mem.emoji)
                    .font(.system(size: 26))
                    .frame(width: 44, height: 44)
                    .background(Color(hex: colors.accent).opacity(0.2))
                    .clipShape(Rectangle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(mem.title)
                        .appFont(size: 16, weight: .bold, relativeTo: .body)
                        .foregroundStyle(Color(hex: colors.ink))

                    HStack(spacing: 6) {
                        Text(mem.shortDate)
                            .appFont(size: 11, weight: .medium, relativeTo: .caption)
                            .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.6))

                        if let space = mem.spaceTitle {
                            Text("· \(space)")
                                .appFont(size: 11, weight: .bold, relativeTo: .caption)
                                .foregroundStyle(Color(hex: colors.accent))
                        }
                    }
                }

                Spacer()

                Text("\(mem.notes.count) \(DayEventStore.language == "tr" ? "not" : "notes")")
                    .appFont(size: 11, weight: .bold, relativeTo: .caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: colors.ink).opacity(0.06))
                    .clipShape(Rectangle())
            }

            if !mem.notes.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(mem.notes.prefix(3)) { note in
                        notePreviewRow(note)
                    }
                }
                .padding(10)
                .background(Color(hex: colors.ink).opacity(0.04))
                .clipShape(Rectangle())
            }
        }
        .padding(14)
        .background(Color(hex: colors.backdropRaised).opacity(0.94))
        .clipShape(Rectangle())
    }

    private func notePreviewRow(_ note: CapsuleNote) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Text("✉️")
                .font(.system(size: 11))
            Text("\(note.authorName.isEmpty ? "Arkadaşın" : note.authorName):")
                .appFont(size: 11, weight: .bold, relativeTo: .caption2)
                .foregroundStyle(Color(hex: colors.ink))
            Text(note.content)
                .appFont(size: 11, weight: .medium, relativeTo: .caption2)
                .lineLimit(1)
                .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.7))
        }
    }
}
