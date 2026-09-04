import SwiftUI

struct NewBetSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var betStore: DayBetStore

    let dayID: String
    let targetMonth: Int
    let targetDay: Int
    let colors: ThemeColors
    let onCreated: ((DayBet) -> Void)?

    @State private var title: String = ""
    @State private var stake: String = ""
    @State private var partyA: String = ""
    @State private var partyB: String = ""
    @State private var isSubmitting: Bool = false

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !stake.trimmingCharacters(in: .whitespaces).isEmpty &&
        !partyA.trimmingCharacters(in: .whitespaces).isEmpty &&
        !partyB.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        ZStack {
            EditorialBackground(colors: colors, elapsed: 0)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    titleSection
                    stakeSection
                    partiesSection
                    sealNoticeSection
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
                HStack(spacing: 8) {
                    Text("🤝")
                        .font(.system(size: 24))
                    Text(DayEventStore.language == "tr" ? "İddia Mühürle" : "Seal a Bet")
                        .font(.system(size: 30, weight: .semibold, design: .serif))
                        .tracking(-0.6)
                }

                Text(DayEventStore.language == "tr"
                     ? "O gün geldiğinde kazanan seçilecek ve Zafer Makbuzu basılacak."
                     : "When the day arrives, declare the winner and get a receipt.")
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

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(DayEventStore.language == "tr" ? "İddia Konusu" : "Bet Subject")
                .appFont(size: 12, weight: .black, relativeTo: .caption)
                .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.6))
                .textCase(.uppercase)

            TextField(
                DayEventStore.language == "tr" ? "Örn: Kimin not ortalaması daha yüksek gelecek?" : "e.g. Who runs faster?",
                text: $title
            )
            .appFont(size: 16, weight: .bold, relativeTo: .body)
            .foregroundStyle(Color(hex: colors.ink))
            .padding(.vertical, 4)
        }
        .cardStyle(colors: colors)
    }

    private var stakeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(DayEventStore.language == "tr" ? "Ödül / Ceza (Bedel)" : "The Stake / Penalty")
                .appFont(size: 12, weight: .black, relativeTo: .caption)
                .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.6))
                .textCase(.uppercase)

            TextField(
                DayEventStore.language == "tr" ? "Örn: Kaybeden Kadıköy'de pizza ısmarlar 🍕" : "e.g. Loser buys dinner",
                text: $stake
            )
            .appFont(size: 15, weight: .bold, relativeTo: .body)
            .foregroundStyle(Color(hex: colors.ink))
            .padding(.vertical, 4)
        }
        .cardStyle(colors: colors)
    }

    private var partiesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(DayEventStore.language == "tr" ? "Taraflar" : "The Parties")
                .appFont(size: 12, weight: .black, relativeTo: .caption)
                .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.6))
                .textCase(.uppercase)

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(DayEventStore.language == "tr" ? "1. Taraf" : "Party 1")
                        .appFont(size: 11, weight: .bold, relativeTo: .caption2)
                        .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.5))
                    TextField(DayEventStore.language == "tr" ? "Senin Adın" : "Your Name", text: $partyA)
                        .appFont(size: 15, weight: .bold, relativeTo: .body)
                        .foregroundStyle(Color(hex: colors.ink))
                }

                Text("VS")
                    .appFont(size: 14, weight: .black, relativeTo: .caption)
                    .foregroundStyle(Color(hex: colors.accent))

                VStack(alignment: .leading, spacing: 4) {
                    Text(DayEventStore.language == "tr" ? "2. Taraf" : "Party 2")
                        .appFont(size: 11, weight: .bold, relativeTo: .caption2)
                        .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.5))
                    TextField(DayEventStore.language == "tr" ? "Rakip Adı" : "Opponent", text: $partyB)
                        .appFont(size: 15, weight: .bold, relativeTo: .body)
                        .foregroundStyle(Color(hex: colors.ink))
                }
            }
        }
        .cardStyle(colors: colors)
    }

    private var sealNoticeSection: some View {
        HStack(alignment: .top, spacing: 10) {
            Text("🔏")
                .font(.system(size: 18))
            Text(DayEventStore.language == "tr"
                 ? "Bu iddia takvime mühürlenecektir. O gün gelene kadar değiştirilemez. O gün geldiğinde kazananı seçebileceksiniz."
                 : "This bet will be sealed until the date arrives. Then you can declare the winner.")
                .appFont(size: 12, weight: .medium, relativeTo: .caption)
                .foregroundStyle(Color(hex: colors.ink).opacity(0.8))
        }
        .padding(14)
        .background(Color(hex: colors.accent).opacity(0.2))
        .clipShape(Rectangle())
    }

    private var submitButton: some View {
        Button {
            create()
        } label: {
            HStack {
                if isSubmitting {
                    ProgressView().tint(Color(hex: colors.ink))
                } else {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 16, weight: .bold))
                    Text(DayEventStore.language == "tr" ? "İddiayı Mühürle" : "Seal Bet")
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

    private func create() {
        guard isValid else { return }
        isSubmitting = true

        let bet = betStore.addBet(
            dayID: dayID,
            title: title,
            stake: stake,
            partyA: partyA,
            partyB: partyB,
            targetMonth: targetMonth,
            targetDay: targetDay
        )

        isSubmitting = false
        onCreated?(bet)
        dismiss()
    }
}

private extension View {
    func cardStyle(colors: ThemeColors) -> some View {
        self
            .foregroundStyle(Color(hex: colors.onBackdrop))
            .editorialSurface(colors: colors, padding: 16)
    }
}
