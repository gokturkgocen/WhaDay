import SwiftUI

struct CustomDayImportSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var customDayStore: CustomDayStore

    let record: CustomDayRecord
    let onAccepted: (DayEvent) -> Void

    private var colors: ThemeColors {
        ThemeColors.forEvent(record.toDayEvent())
    }

    private var formattedDate: String {
        var comps = DateComponents()
        comps.month = record.month
        comps.day = record.day
        let formatter = DateFormatter()
        formatter.locale = DayEventStore.dateLocale
        formatter.dateFormat = "d MMMM"
        let date = Calendar.current.date(from: comps) ?? Date()
        return formatter.string(from: date)
    }

    var body: some View {
        ZStack {
            EditorialBackground(colors: colors, elapsed: 0)

            VStack(spacing: 24) {
                // Top handle/close
                HStack {
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

                Spacer()

                // Invitation preview card
                VStack(spacing: 16) {
                    Text(record.emoji)
                        .font(.system(size: 64))

                    VStack(spacing: 6) {
                        if let author = record.authorName, !author.isEmpty {
                            Text(DayEventStore.language == "tr" ? "\(author) seninle bir gün paylaştı" : "\(author) shared a day with you")
                                .appFont(size: 13, weight: .bold, relativeTo: .subheadline)
                                .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.6))
                                .textCase(.uppercase)
                                .tracking(0.5)
                        }

                        Text(record.title)
                            .appFont(size: 28, weight: .black, relativeTo: .title)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color(hex: colors.ink))

                        Text(formattedDate)
                            .appFont(size: 15, weight: .bold, relativeTo: .subheadline)
                            .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.7))
                    }

                    Text(record.description)
                        .appFont(size: 15, weight: .medium, relativeTo: .body)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .foregroundStyle(Color(hex: colors.ink).opacity(0.85))
                        .padding(.horizontal, 8)
                }
                .padding(24)
                .background(Color(hex: colors.ink).opacity(0.05))
                .clipShape(Rectangle())
                .overlay(
                    Rectangle()
                        .stroke(Color(hex: colors.ink).opacity(0.1), lineWidth: 1)
                )

                Text(DayEventStore.language == "tr"
                     ? "Bu günü kabul ettiğinde her yıl bu tarihte WhaDay'inde senin için görünecek."
                     : "When added, this occasion will appear on this date every year in your WhaDay.")
                    .appFont(size: 12, weight: .semibold, relativeTo: .caption)
                    .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.5))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)

                Spacer()

                // Action buttons
                VStack(spacing: 12) {
                    Button {
                        accept()
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 17, weight: .bold))
                            Text(DayEventStore.language == "tr" ? "Takvimime Ekle" : "Add to My Calendar")
                                .appFont(size: 16, weight: .black, relativeTo: .headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: colors.accent))
                        .foregroundStyle(Color(hex: colors.ink))
                        .clipShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    Button {
                        dismiss()
                    } label: {
                        Text(DayEventStore.language == "tr" ? "Vazgeç" : "Decline")
                            .appFont(size: 14, weight: .bold, relativeTo: .subheadline)
                            .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.6))
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
    }

    private func accept() {
        var updated = record
        updated.isImported = true
        customDayStore.save(updated)
        let event = updated.toDayEvent()
        onAccepted(event)
        dismiss()
    }
}
