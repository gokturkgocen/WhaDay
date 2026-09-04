import SwiftUI

struct NewCapsuleNoteSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var cloudManager: CapsuleCloudManager

    let capsuleID: String
    let targetMonth: Int
    let targetDay: Int
    let dayTitle: String
    let colors: ThemeColors

    @State private var authorName: String = ""
    @State private var content: String = ""
    @State private var isSubmitting: Bool = false
    @State private var showConfirmationAlert: Bool = false

    private var formattedDate: String {
        var comps = DateComponents()
        comps.month = targetMonth
        comps.day = targetDay
        let formatter = DateFormatter()
        formatter.locale = DayEventStore.dateLocale
        formatter.dateFormat = "d MMMM"
        let date = Calendar.current.date(from: comps) ?? Date()
        return formatter.string(from: date)
    }

    private var isValid: Bool {
        !authorName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !content.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        ZStack {
            EditorialBackground(colors: colors, elapsed: 0)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    sealWarningCard
                    authorField
                    contentField
                    actionButton
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 36)
            }
            .scrollIndicators(.hidden)
        }
        .alert(
            DayEventStore.language == "tr" ? "Notu Mühürle" : "Seal Note",
            isPresented: $showConfirmationAlert
        ) {
            Button(DayEventStore.language == "tr" ? "Mühürle ve Gönder" : "Seal & Send", role: .none) {
                submit()
            }
            Button(DayEventStore.language == "tr" ? "Vazgeç" : "Cancel", role: .cancel) {}
        } message: {
            Text(DayEventStore.language == "tr"
                 ? "Bu not \(formattedDate) tarihine kadar hiç kimse tarafından okunamayacak ve silinemeyecektir. Onaylıyor musun?"
                 : "This note cannot be read by anyone until \(formattedDate) and cannot be deleted. Do you confirm?")
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(DayEventStore.language == "tr" ? "Zaman Kapsülüne Not Yaz" : "Add Capsule Note")
                    .font(.system(size: 30, weight: .semibold, design: .serif))
                    .tracking(-0.6)
                Text("\(dayTitle) · \(formattedDate)")
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

    private var sealWarningCard: some View {
        HStack(spacing: 12) {
            Text("🔏")
                .font(.system(size: 28))

            VStack(alignment: .leading, spacing: 3) {
                Text(DayEventStore.language == "tr" ? "Geri Alınamaz Mühür" : "Irreversible Seal")
                    .appFont(size: 13, weight: .black, relativeTo: .headline)
                    .foregroundStyle(Color(hex: colors.ink))

                Text(DayEventStore.language == "tr"
                     ? "Bu not \(formattedDate) tarihine kadar mühürlenecektir. Kimse okuyamaz ve bir daha silinemez."
                     : "This note will be sealed until \(formattedDate). No one can read it and it cannot be deleted.")
                    .appFont(size: 11, weight: .medium, relativeTo: .caption)
                    .foregroundStyle(Color(hex: colors.ink).opacity(0.75))
            }
        }
        .padding(16)
        .background(Color(hex: colors.accent).opacity(0.25))
        .clipShape(Rectangle())
        .overlay(
            Rectangle()
                .stroke(Color(hex: colors.accent).opacity(0.5), lineWidth: 1)
        )
    }

    private var authorField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(DayEventStore.language == "tr" ? "Adın / Rumuzun" : "Your Name")
                .appFont(size: 12, weight: .black, relativeTo: .caption)
                .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.6))
                .textCase(.uppercase)

            TextField(
                DayEventStore.language == "tr" ? "Örn: Ahmet" : "e.g. Alex",
                text: $authorName
            )
            .appFont(size: 16, weight: .bold, relativeTo: .body)
            .foregroundStyle(Color(hex: colors.ink))
            .padding(.vertical, 4)
        }
        .cardStyle(colors: colors)
    }

    private var contentField: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(DayEventStore.language == "tr" ? "Kapsül Notun" : "Your Note")
                    .appFont(size: 12, weight: .black, relativeTo: .caption)
                    .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.6))
                    .textCase(.uppercase)
                Spacer()
                Text("\(content.count)/300")
                    .appFont(size: 11, weight: .semibold, relativeTo: .caption2)
                    .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.4))
            }

            TextField(
                DayEventStore.language == "tr" ? "O gün geldiğinde herkesin okuyacağı bir mesaj bırak..." : "Leave a message for when that day arrives...",
                text: $content,
                axis: .vertical
            )
            .lineLimit(4...7)
            .appFont(size: 15, weight: .medium, relativeTo: .body)
            .foregroundStyle(Color(hex: colors.ink))
            .padding(.vertical, 4)
            .onChange(of: content) { _, newValue in
                if newValue.count > 300 {
                    content = String(newValue.prefix(300))
                }
            }
        }
        .cardStyle(colors: colors)
    }

    private var actionButton: some View {
        Button {
            showConfirmationAlert = true
        } label: {
            HStack {
                if isSubmitting {
                    ProgressView()
                        .tint(Color(hex: colors.ink))
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 15, weight: .black))
                    Text(DayEventStore.language == "tr" ? "Mühürle ve Kapsüle At 🔏" : "Seal & Lock in Capsule 🔏")
                        .appFont(size: 15, weight: .black, relativeTo: .headline)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isValid ? Color(hex: colors.accent) : Color(hex: colors.ink).opacity(0.1))
            .foregroundStyle(isValid ? Color(hex: colors.ink) : Color(hex: colors.onBackdrop).opacity(0.4))
            .clipShape(Rectangle())
        }
        .disabled(!isValid || isSubmitting)
        .buttonStyle(.plain)
    }

    private func submit() {
        guard isValid else { return }
        isSubmitting = true

        Task {
            try? await cloudManager.submitNote(
                capsuleID: capsuleID,
                authorName: authorName,
                content: content,
                targetMonth: targetMonth,
                targetDay: targetDay
            )
            isSubmitting = false
            dismiss()
        }
    }
}

private extension View {
    func cardStyle(colors: ThemeColors) -> some View {
        self
            .foregroundStyle(Color(hex: colors.onBackdrop))
            .editorialSurface(colors: colors)
    }
}
