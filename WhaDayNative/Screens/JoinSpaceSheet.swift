import SwiftUI

struct JoinSpaceSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var spaceManager: SharedSpaceManager

    let space: SharedSpace
    let onJoined: ((SharedSpace) -> Void)?

    @State private var memberName: String = ""
    @State private var isJoining: Bool = false

    private var colors: ThemeColors {
        ThemeColors.forCategory("celebration")
    }

    private var isValid: Bool {
        !memberName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        ZStack {
            EditorialBackground(colors: colors, elapsed: 0)

            VStack(spacing: 24) {
                HStack {
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

                Spacer()

                VStack(spacing: 16) {
                    Text(space.emoji)
                        .font(.system(size: 64))

                    VStack(spacing: 6) {
                        Text(DayEventStore.language == "tr"
                             ? "\(space.creatorName) seni ortak takvime davet etti"
                             : "\(space.creatorName) invited you to a shared space")
                            .appFont(size: 13, weight: .bold, relativeTo: .subheadline)
                            .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.6))
                            .textCase(.uppercase)
                            .tracking(0.5)

                        Text(space.title)
                            .appFont(size: 28, weight: .black, relativeTo: .title)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color(hex: colors.ink))
                    }

                    Text(DayEventStore.language == "tr"
                         ? "Katıldığında ikinizin de eklediği özel günler, sayaçlar ve mühürlü notlar ortak takviminize canlı düşecek."
                         : "Once joined, custom dates, countdowns, and sealed notes will sync automatically.")
                        .appFont(size: 13, weight: .medium, relativeTo: .footnote)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color(hex: colors.ink).opacity(0.8))
                        .padding(.horizontal, 10)
                }
                .padding(24)
                .background(Color(hex: colors.ink).opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color(hex: colors.ink).opacity(0.1), lineWidth: 1)
                )

                // Name input
                VStack(alignment: .leading, spacing: 6) {
                    Text(DayEventStore.language == "tr" ? "Takvimde Görünecek Adın" : "Your Name")
                        .appFont(size: 12, weight: .black, relativeTo: .caption)
                        .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.6))
                        .textCase(.uppercase)

                    TextField(
                        DayEventStore.language == "tr" ? "Örn: Zeynep" : "e.g. Sam",
                        text: $memberName
                    )
                    .appFont(size: 16, weight: .bold, relativeTo: .body)
                    .foregroundStyle(Color(hex: colors.ink))
                    .padding(14)
                    .background(Color(hex: colors.backdropRaised).opacity(0.94))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color(hex: colors.ink).opacity(0.12), lineWidth: 1)
                    )
                }

                Spacer()

                VStack(spacing: 12) {
                    Button {
                        join()
                    } label: {
                        HStack {
                            if isJoining {
                                ProgressView().tint(Color(hex: colors.ink))
                            } else {
                                Image(systemName: "person.2.fill")
                                    .font(.system(size: 16, weight: .bold))
                                Text(DayEventStore.language == "tr" ? "Ortak Takvime Katıl" : "Join Shared Space")
                                    .appFont(size: 16, weight: .black, relativeTo: .headline)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(isValid ? Color(hex: colors.accent) : Color(hex: colors.ink).opacity(0.1))
                        .foregroundStyle(isValid ? Color(hex: colors.ink) : Color(hex: colors.onBackdrop).opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                    .disabled(!isValid || isJoining)
                    .buttonStyle(.plain)

                    Button {
                        dismiss()
                    } label: {
                        Text(DayEventStore.language == "tr" ? "Vazgeç" : "Cancel")
                            .appFont(size: 14, weight: .bold, relativeTo: .subheadline)
                            .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.6))
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
    }

    private func join() {
        guard isValid else { return }
        isJoining = true

        Task {
            try? await spaceManager.joinSpace(space: space, memberName: memberName)
            isJoining = false
            onJoined?(space)
            dismiss()
        }
    }
}
