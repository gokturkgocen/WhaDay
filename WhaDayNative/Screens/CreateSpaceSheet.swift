import SwiftUI

struct CreateSpaceSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var spaceManager: SharedSpaceManager

    let colors: ThemeColors
    let onCreated: ((SharedSpace) -> Void)?

    @State private var title: String = ""
    @State private var creatorName: String = ""
    @State private var selectedEmoji: String = "❤️"
    @State private var isCreating: Bool = false

    private let quickEmojis = ["❤️", "🏖️", "🍕", "🥂", "🚀", "🐶", "🌿", "🌟", "💍", "☕"]

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !creatorName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        ZStack {
            EditorialBackground(colors: colors, elapsed: 0)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    emojiPicker
                    titleSection
                    creatorSection
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
                Text(DayEventStore.language == "tr" ? "Ortak Takvim Başlat" : "Create Shared Space")
                    .appFont(size: 24, weight: .black, relativeTo: .title2)
                    .tracking(-0.6)
                Text(DayEventStore.language == "tr" ? "Çiftler veya yakın arkadaşlar için canlı alan" : "For couples or close friend groups")
                    .appFont(size: 13, weight: .bold, relativeTo: .subheadline)
                    .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.6))
            }

            Spacer()

            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .black))
                    .frame(width: 44, height: 44)
                    .background(Color(hex: colors.ink).opacity(0.06))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .foregroundStyle(Color(hex: colors.onBackdrop))
        .padding(.top, 10)
    }

    private var emojiPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(DayEventStore.language == "tr" ? "Alan Simgesi" : "Space Emoji")
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
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
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
            Text(DayEventStore.language == "tr" ? "Ortak Alan Adı" : "Space Name")
                .appFont(size: 12, weight: .black, relativeTo: .caption)
                .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.6))
                .textCase(.uppercase)

            TextField(
                DayEventStore.language == "tr" ? "Örn: Göktürk & Zeynep veya Bizim Tayfa" : "e.g. Alex & Sam",
                text: $title
            )
            .appFont(size: 16, weight: .bold, relativeTo: .body)
            .foregroundStyle(Color(hex: colors.ink))
            .padding(.vertical, 4)
        }
        .cardStyle(colors: colors)
    }

    private var creatorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(DayEventStore.language == "tr" ? "Senin Adın" : "Your Name")
                .appFont(size: 12, weight: .black, relativeTo: .caption)
                .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.6))
                .textCase(.uppercase)

            TextField(
                DayEventStore.language == "tr" ? "Örn: Göktürk" : "e.g. Alex",
                text: $creatorName
            )
            .appFont(size: 16, weight: .bold, relativeTo: .body)
            .foregroundStyle(Color(hex: colors.ink))
            .padding(.vertical, 4)
        }
        .cardStyle(colors: colors)
    }

    private var submitButton: some View {
        Button {
            create()
        } label: {
            HStack {
                if isCreating {
                    ProgressView().tint(Color(hex: colors.ink))
                } else {
                    Image(systemName: "sparkles")
                        .font(.system(size: 15, weight: .black))
                    Text(DayEventStore.language == "tr" ? "Ortak Alanı Başlat" : "Create Shared Space")
                        .appFont(size: 15, weight: .black, relativeTo: .headline)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isValid ? Color(hex: colors.accent) : Color(hex: colors.ink).opacity(0.1))
            .foregroundStyle(isValid ? Color(hex: colors.ink) : Color(hex: colors.onBackdrop).opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .disabled(!isValid || isCreating)
        .buttonStyle(.plain)
    }

    private func create() {
        guard isValid else { return }
        isCreating = true

        Task {
            if let space = try? await spaceManager.createSpace(
                title: title,
                emoji: selectedEmoji,
                creatorName: creatorName
            ) {
                isCreating = false
                onCreated?(space)
                dismiss()
            } else {
                isCreating = false
            }
        }
    }
}

private extension View {
    func cardStyle(colors: ThemeColors) -> some View {
        self
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(Color(hex: colors.onBackdrop))
            .background(Color(hex: colors.backdropRaised).opacity(0.94))
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(Color(hex: colors.ink).opacity(0.12), lineWidth: 1)
            )
    }
}
