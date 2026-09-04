import SwiftUI

struct NewSharedEventSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var spaceManager: SharedSpaceManager

    let spaceID: String
    let spaceTitle: String
    let colors: ThemeColors
    let onAdded: ((SharedSpaceEvent) -> Void)?

    @State private var month: Int = Calendar.current.component(.month, from: Date())
    @State private var day: Int = Calendar.current.component(.day, from: Date())
    @State private var title: String = ""
    @State private var descriptionText: String = ""
    @State private var selectedEmoji: String = "✨"
    @State private var authorName: String = ""
    @State private var isSaving: Bool = false

    private let quickEmojis = ["✨", "❤️", "🏖️", "💍", "🍕", "🎂", "🥂", "🎉", "✈️", "☕", "🍿", "🌟"]

    private var formattedDate: String {
        var comps = DateComponents()
        comps.month = month
        comps.day = day
        let formatter = DateFormatter()
        formatter.locale = DayEventStore.dateLocale
        formatter.dateFormat = "d MMMM"
        let date = Calendar.current.date(from: comps) ?? Date()
        return formatter.string(from: date)
    }

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !descriptionText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        ZStack {
            EditorialBackground(colors: colors, elapsed: 0)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    datePickerSection
                    emojiPicker
                    titleSection
                    descriptionSection
                    authorSection
                    submitButton
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 36)
            }
            .scrollIndicators(.hidden)
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(DayEventStore.language == "tr" ? "Yeni Ortak Gün Ekle" : "Add Shared Day")
                    .font(.system(size: 30, weight: .semibold, design: .serif))
                    .tracking(-0.6)
                Text("'\(spaceTitle)'")
                    .appFont(size: 14, weight: .bold, relativeTo: .subheadline)
                    .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.6))
            }

            Spacer()

            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color(hex: colors.onBackdrop))
                    .frame(width: 36, height: 36)
                    .background(Color(hex: colors.ink).opacity(0.06))
                    .clipShape(Rectangle())
                    .overlay(Rectangle().strokeBorder(Color(hex: colors.ink).opacity(0.12), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .minimumAccessibleTarget()
            .accessibilityLabel(DayEventStore.language == "tr" ? "Kapat" : "Close")
        }
        .foregroundStyle(Color(hex: colors.onBackdrop))
        .padding(.top, 24)
        .padding(.bottom, 8)
    }

    private var datePickerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(DayEventStore.language == "tr" ? "Tarih Seçimi" : "Date")
                .appFont(size: 12, weight: .black, relativeTo: .caption)
                .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.6))
                .textCase(.uppercase)

            HStack(spacing: 12) {
                Picker("Ay", selection: $month) {
                    ForEach(1...12, id: \.self) { m in
                        Text(monthName(m)).tag(m)
                    }
                }
                .pickerStyle(.menu)
                .tint(Color(hex: colors.ink))

                Picker("Gün", selection: $day) {
                    ForEach(1...31, id: \.self) { d in
                        Text("\(d)").tag(d)
                    }
                }
                .pickerStyle(.menu)
                .tint(Color(hex: colors.ink))

                Spacer()

                Text(formattedDate)
                    .appFont(size: 14, weight: .bold, relativeTo: .subheadline)
                    .foregroundStyle(Color(hex: colors.accent))
            }
        }
        .cardStyle(colors: colors)
    }

    private var emojiPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(DayEventStore.language == "tr" ? "Gün Emojisi" : "Day Emoji")
                .appFont(size: 12, weight: .black, relativeTo: .caption)
                .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.6))
                .textCase(.uppercase)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(quickEmojis, id: \.self) { emoji in
                        Button {
                            Haptics.triggerLight()
                            selectedEmoji = emoji
                        } label: {
                            Text(emoji)
                                .font(.system(size: 26))
                                .frame(width: 48, height: 48)
                                .background(selectedEmoji == emoji ? Color(hex: colors.accent) : Color(hex: colors.ink).opacity(0.06))
                                .clipShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .cardStyle(colors: colors)
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(DayEventStore.language == "tr" ? "Günün Başlığı" : "Title")
                .appFont(size: 12, weight: .black, relativeTo: .caption)
                .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.6))
                .textCase(.uppercase)

            TextField(
                DayEventStore.language == "tr" ? "Örn: Marmaris Tatili veya Yıldönümümüz" : "e.g. Summer Vacation",
                text: $title
            )
            .appFont(size: 16, weight: .bold, relativeTo: .body)
            .foregroundStyle(Color(hex: colors.ink))
            .padding(.vertical, 4)
        }
        .cardStyle(colors: colors)
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(DayEventStore.language == "tr" ? "Açıklama / Hatıra" : "Description")
                .appFont(size: 12, weight: .black, relativeTo: .caption)
                .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.6))
                .textCase(.uppercase)

            TextField(
                DayEventStore.language == "tr" ? "Örn: Birlikte geçireceğimiz harika bir hafta." : "e.g. A memorable week together.",
                text: $descriptionText,
                axis: .vertical
            )
            .lineLimit(3...5)
            .appFont(size: 14, weight: .medium, relativeTo: .body)
            .foregroundStyle(Color(hex: colors.ink))
            .padding(.vertical, 4)
        }
        .cardStyle(colors: colors)
    }

    private var authorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(DayEventStore.language == "tr" ? "Ekleyen (Senin Adın)" : "Added By")
                .appFont(size: 12, weight: .black, relativeTo: .caption)
                .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.6))
                .textCase(.uppercase)

            TextField(
                DayEventStore.language == "tr" ? "Örn: Deniz" : "e.g. Alex",
                text: $authorName
            )
            .appFont(size: 15, weight: .semibold, relativeTo: .body)
            .foregroundStyle(Color(hex: colors.ink))
            .padding(.vertical, 4)
        }
        .cardStyle(colors: colors)
    }

    private var submitButton: some View {
        Button {
            save()
        } label: {
            HStack {
                if isSaving {
                    ProgressView().tint(Color(hex: colors.ink))
                } else {
                    Image(systemName: "checkmark")
                        .font(.system(size: 15, weight: .black))
                    Text(DayEventStore.language == "tr" ? "Ortak Takvime Kaydet" : "Save to Shared Calendar")
                        .appFont(size: 15, weight: .black, relativeTo: .headline)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isValid ? Color(hex: colors.accent) : Color(hex: colors.ink).opacity(0.1))
            .foregroundStyle(isValid ? Color(hex: colors.ink) : Color(hex: colors.onBackdrop).opacity(0.4))
            .clipShape(Rectangle())
        }
        .disabled(!isValid || isSaving)
        .buttonStyle(.plain)
    }

    private func save() {
        guard isValid else { return }
        isSaving = true

        Task {
            if let event = try? await spaceManager.addEvent(
                spaceID: spaceID,
                month: month,
                day: day,
                title: title,
                description: descriptionText,
                emoji: selectedEmoji,
                author: authorName
            ) {
                isSaving = false
                onAdded?(event)
                dismiss()
            } else {
                isSaving = false
            }
        }
    }

    private func monthName(_ m: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = DayEventStore.dateLocale
        return formatter.monthSymbols[m - 1]
    }
}

private extension View {
    func cardStyle(colors: ThemeColors) -> some View {
        self
            .foregroundStyle(Color(hex: colors.onBackdrop))
            .editorialSurface(colors: colors)
    }
}
