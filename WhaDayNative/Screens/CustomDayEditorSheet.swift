import SwiftUI

struct CustomDayEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var customDayStore: CustomDayStore

    let dayID: String
    let month: Int
    let day: Int
    let colors: ThemeColors
    let onSaved: ((DayEvent) -> Void)?

    @State private var title: String
    @State private var descriptionText: String
    @State private var selectedEmoji: String
    @State private var authorName: String
    @State private var showingShareSheet = false
    @State private var shareURL: URL?

    private let quickEmojis = ["🎂", "🎉", "💍", "❤️", "🌟", "☕", "🚀", "🥂", "🎓", "🐶", "🍕", "🌸"]

    init(
        dayID: String,
        month: Int,
        day: Int,
        colors: ThemeColors,
        existingRecord: CustomDayRecord? = nil,
        defaultEvent: DayEvent? = nil,
        onSaved: ((DayEvent) -> Void)? = nil
    ) {
        self.dayID = dayID
        self.month = month
        self.day = day
        self.colors = colors
        self.onSaved = onSaved

        _title = State(initialValue: existingRecord?.title ?? defaultEvent?.title ?? "")
        _descriptionText = State(initialValue: existingRecord?.description ?? defaultEvent?.description ?? "")
        _selectedEmoji = State(initialValue: existingRecord?.emoji ?? defaultEvent?.emoji ?? "✨")
        _authorName = State(initialValue: existingRecord?.authorName ?? "")
    }

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
                    emojiPicker
                    titleSection
                    descriptionSection
                    authorSection
                    actionButtons
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 36)
            }
            .scrollIndicators(.hidden)
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = shareURL {
                ShareSheet(items: [
                    "\(selectedEmoji) \(title) (\(formattedDate))\n\(descriptionText)\n\nBu günü WhaDay takvimine ekle: \(url.absoluteString)"
                ])
                .presentationDetents([.medium, .large])
            }
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(DayEventStore.language == "tr" ? "Kendi Gününü Belirle" : "Personalize This Day")
                    .font(.system(size: 30, weight: .semibold, design: .serif))
                    .tracking(-0.6)
                Text(formattedDate)
                    .appFont(size: 14, weight: .bold, relativeTo: .subheadline)
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

    private var emojiPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(DayEventStore.language == "tr" ? "Günün Emojisi" : "Day Emoji")
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
                                .overlay(
                                    Rectangle()
                                        .stroke(Color(hex: colors.ink).opacity(selectedEmoji == emoji ? 0.2 : 0), lineWidth: 1.5)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .editorCard(colors: colors)
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(DayEventStore.language == "tr" ? "Günün Başlığı" : "Title")
                    .appFont(size: 12, weight: .black, relativeTo: .caption)
                    .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.6))
                    .textCase(.uppercase)
                Spacer()
                Text("\(title.count)/40")
                    .appFont(size: 11, weight: .semibold, relativeTo: .caption2)
                    .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.4))
            }

            TextField(
                DayEventStore.language == "tr" ? "Örn: Benim Doğum Günüm" : "e.g. My Birthday",
                text: $title
            )
            .appFont(size: 16, weight: .bold, relativeTo: .body)
            .foregroundStyle(Color(hex: colors.ink))
            .padding(.vertical, 6)
            .onChange(of: title) { _, newValue in
                if newValue.count > 40 {
                    title = String(newValue.prefix(40))
                }
            }
        }
        .editorCard(colors: colors)
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(DayEventStore.language == "tr" ? "Hikaye / Açıklama" : "Description")
                    .appFont(size: 12, weight: .black, relativeTo: .caption)
                    .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.6))
                    .textCase(.uppercase)
                Spacer()
                Text("\(descriptionText.count)/180")
                    .appFont(size: 11, weight: .semibold, relativeTo: .caption2)
                    .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.4))
            }

            TextField(
                DayEventStore.language == "tr" ? "Örn: Bu gün bana pasta yemeyi ve kutlamayı hatırlatıyor." : "e.g. A day to celebrate with friends.",
                text: $descriptionText,
                axis: .vertical
            )
            .lineLimit(3...5)
            .appFont(size: 14, weight: .medium, relativeTo: .body)
            .foregroundStyle(Color(hex: colors.ink))
            .padding(.vertical, 4)
            .onChange(of: descriptionText) { _, newValue in
                if newValue.count > 180 {
                    descriptionText = String(newValue.prefix(180))
                }
            }
        }
        .editorCard(colors: colors)
    }

    private var authorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(DayEventStore.language == "tr" ? "Senin Adın (Paylaşırken Görünür)" : "Your Name (Optional)")
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
        .editorCard(colors: colors)
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                save()
            } label: {
                HStack {
                    Image(systemName: "checkmark")
                        .font(.system(size: 15, weight: .black))
                    Text(DayEventStore.language == "tr" ? "Takvime Kaydet" : "Save to Calendar")
                        .appFont(size: 15, weight: .black, relativeTo: .headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isValid ? Color(hex: colors.accent) : Color(hex: colors.ink).opacity(0.1))
                .foregroundStyle(isValid ? Color(hex: colors.ink) : Color(hex: colors.onBackdrop).opacity(0.4))
                .clipShape(Rectangle())
            }
            .disabled(!isValid)
            .buttonStyle(.plain)

            if customDayStore.isCustom(dayID: dayID) {
                Button {
                    shareWithFriends()
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 15, weight: .bold))
                        Text(DayEventStore.language == "tr" ? "Arkadaşlarına Gönder" : "Share With Friends")
                            .appFont(size: 14, weight: .black, relativeTo: .headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(hex: colors.ink).opacity(0.06))
                    .foregroundStyle(Color(hex: colors.onBackdrop))
                    .clipShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func save() {
        guard isValid else { return }
        let record = CustomDayRecord(
            id: dayID,
            month: month,
            day: day,
            title: title.trimmingCharacters(in: .whitespaces),
            description: descriptionText.trimmingCharacters(in: .whitespaces),
            emoji: selectedEmoji,
            authorName: authorName.trimmingCharacters(in: .whitespaces).isEmpty ? nil : authorName.trimmingCharacters(in: .whitespaces),
            isImported: false
        )
        customDayStore.save(record)
        let event = record.toDayEvent()
        onSaved?(event)
        dismiss()
    }

    private func shareWithFriends() {
        let record = CustomDayRecord(
            id: dayID,
            month: month,
            day: day,
            title: title.trimmingCharacters(in: .whitespaces),
            description: descriptionText.trimmingCharacters(in: .whitespaces),
            emoji: selectedEmoji,
            authorName: authorName.trimmingCharacters(in: .whitespaces).isEmpty ? nil : authorName.trimmingCharacters(in: .whitespaces),
            isImported: false
        )
        shareURL = record.webShareURL()
        showingShareSheet = true
    }
}

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

private struct EditorCardModifier: ViewModifier {
    let colors: ThemeColors

    func body(content: Content) -> some View {
        content
            .foregroundStyle(Color(hex: colors.onBackdrop))
            .editorialSurface(colors: colors)
    }
}

private extension View {
    func editorCard(colors: ThemeColors) -> some View {
        modifier(EditorCardModifier(colors: colors))
    }
}
