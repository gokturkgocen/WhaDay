import SwiftUI

struct BetSectionView: View {
    @EnvironmentObject private var betStore: DayBetStore

    let dayID: String
    let targetMonth: Int
    let targetDay: Int
    let colors: ThemeColors

    @State private var showingNewBetSheet = false
    @State private var activeReceiptBet: DayBet?

    private var bets: [DayBet] {
        betStore.bets(for: dayID)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Text("🤝")
                        .font(.system(size: 14))
                    Text(DayEventStore.language == "tr" ? "ARKADAŞ İDDİASI" : "FRIEND BETS")
                        .appFont(size: 12, weight: .black, relativeTo: .caption)
                        .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.6))
                        .tracking(1.2)
                }

                Spacer()

                Button {
                    Haptics.triggerLight()
                    showingNewBetSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: 10, weight: .black))
                        Text(DayEventStore.language == "tr" ? "İddia Ekle" : "Add Bet")
                            .appFont(size: 11, weight: .bold, relativeTo: .caption2)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(hex: colors.ink).opacity(0.06))
                    .foregroundStyle(Color(hex: colors.onBackdrop))
                    .clipShape(Rectangle())
                }
                .buttonStyle(.plain)
            }

            if bets.isEmpty {
                Button {
                    Haptics.triggerLight()
                    showingNewBetSheet = true
                } label: {
                    HStack(spacing: 12) {
                        Text("🤝")
                            .font(.system(size: 26))
                            .frame(width: 44, height: 44)
                            .background(Color(hex: colors.accent).opacity(0.2))
                            .clipShape(Rectangle())

                        VStack(alignment: .leading, spacing: 2) {
                            Text(DayEventStore.language == "tr" ? "Bu Güne Bir İddia Mühürle" : "Seal a Bet for This Day")
                                .appFont(size: 14, weight: .bold, relativeTo: .body)
                                .foregroundStyle(Color(hex: colors.ink))

                            Text(DayEventStore.language == "tr"
                                 ? "Günü geldiğinde kazanan belirlenir ve resmi borç senedi basılır."
                                 : "When the day comes, declare the winner & get a receipt.")
                                .appFont(size: 11, weight: .medium, relativeTo: .caption)
                                .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.6))
                        }

                        Spacer()
                    }
                    .padding(12)
                    .background(Color(hex: colors.backdropRaised).opacity(0.7))
                    .clipShape(Rectangle())
                }
                .buttonStyle(.plain)
            } else {
                ForEach(bets) { bet in
                    betRow(bet)
                }
            }
        }
        .sheet(isPresented: $showingNewBetSheet) {
            NewBetSheet(
                dayID: dayID,
                targetMonth: targetMonth,
                targetDay: targetDay,
                colors: colors
            ) { _ in }
            .presentationDetents([.large])
        }
        .sheet(item: $activeReceiptBet) { bet in
            BetReceiptSheet(bet: bet, colors: colors)
                .presentationDetents([.large])
        }
    }

    private func betRow(_ bet: DayBet) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(bet.title)
                    .appFont(size: 15, weight: .bold, relativeTo: .headline)
                    .foregroundStyle(Color(hex: colors.ink))

                Spacer()

                if bet.isResolved {
                    Text("✅")
                        .font(.system(size: 13))
                } else if bet.isLocked() {
                    Text("🔒")
                        .font(.system(size: 13))
                } else {
                    Text("⚡️")
                        .font(.system(size: 13))
                }
            }

            Text("🍕 \(bet.stake)")
                .appFont(size: 12, weight: .semibold, relativeTo: .caption)
                .foregroundStyle(Color(hex: colors.accent))

            if let winner = bet.winner {
                HStack {
                    Text(DayEventStore.language == "tr" ? "🏆 Kazanan: \(winner)" : "🏆 Winner: \(winner)")
                        .appFont(size: 12, weight: .black, relativeTo: .caption)
                        .foregroundStyle(Color(hex: colors.ink))

                    Spacer()

                    Button {
                        activeReceiptBet = bet
                    } label: {
                        Text(DayEventStore.language == "tr" ? "Borç Senedi" : "Receipt")
                            .appFont(size: 11, weight: .black, relativeTo: .caption2)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color(hex: colors.accent))
                            .foregroundStyle(Color(hex: colors.ink))
                            .clipShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 2)
            } else if bet.isLocked() {
                Text(DayEventStore.language == "tr"
                     ? "🔏 \(bet.partyA) vs \(bet.partyB) · \(bet.formattedTargetDate)'de açılacak"
                     : "🔏 \(bet.partyA) vs \(bet.partyB) · Unlocks on \(bet.formattedTargetDate)")
                    .appFont(size: 11, weight: .medium, relativeTo: .caption2)
                    .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.6))
            } else {
                // Unlocked! Vote for winner
                VStack(alignment: .leading, spacing: 6) {
                    Text(DayEventStore.language == "tr" ? "KAZANAN KİM OLDU?" : "WHO WON?")
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                        .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.6))

                    HStack(spacing: 8) {
                        Button {
                            resolve(bet: bet, winner: bet.partyA)
                        } label: {
                            Text("🏆 \(bet.partyA)")
                                .appFont(size: 12, weight: .bold, relativeTo: .caption)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color(hex: colors.accent))
                                .foregroundStyle(Color(hex: colors.ink))
                                .clipShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        Button {
                            resolve(bet: bet, winner: bet.partyB)
                        } label: {
                            Text("🏆 \(bet.partyB)")
                                .appFont(size: 12, weight: .bold, relativeTo: .caption)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color(hex: colors.ink).opacity(0.08))
                                .foregroundStyle(Color(hex: colors.ink))
                                .clipShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(14)
        .background(Color(hex: colors.backdropRaised).opacity(0.94))
        .clipShape(Rectangle())
        .overlay(
            Rectangle()
                .strokeBorder(Color(hex: colors.ink).opacity(0.1), lineWidth: 1)
        )
    }

    private func resolve(bet: DayBet, winner: String) {
        betStore.resolveBet(betID: bet.id, dayID: dayID, winner: winner)
        if var updated = betStore.bets(for: dayID).first(where: { $0.id == bet.id }) {
            updated.winner = winner
            activeReceiptBet = updated
        }
    }
}
