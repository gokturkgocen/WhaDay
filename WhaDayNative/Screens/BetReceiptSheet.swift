import SwiftUI

struct BetReceiptSheet: View {
    @Environment(\.dismiss) private var dismiss

    let bet: DayBet
    let colors: ThemeColors

    @State private var showingShareSheet = false

    private var shareText: String {
        guard let win = bet.winner else { return "" }
        let loser = bet.loser() ?? "Rakip"
        return """
        📜 WhaDay RESMİ BORÇ SENEDİ
        İddia: \(bet.title)
        🏆 KAZANAN: \(win)
        💸 BORÇLU: \(loser)
        🍕 BEDEL: \(bet.stake)
        Tarih: \(bet.formattedTargetDate)
        🔏 WhaDay mührüyle tasdik edilmiştir.
        """
    }

    var body: some View {
        ZStack {
            EditorialBackground(colors: colors, elapsed: 0)

            VStack(spacing: 20) {
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

                // The Official Receipt Card
                receiptCard

                Spacer()

                Button {
                    showingShareSheet = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 15, weight: .bold))
                        Text(DayEventStore.language == "tr" ? "Borç Senedini Paylaş" : "Share Voucher")
                            .appFont(size: 15, weight: .black, relativeTo: .headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: colors.accent))
                    .foregroundStyle(Color(hex: colors.ink))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .sheet(isPresented: $showingShareSheet) {
            ReceiptShareSheet(items: [shareText])
                .presentationDetents([.medium])
        }
    }

    private var receiptCard: some View {
        VStack(spacing: 16) {
            // Receipt Header
            VStack(spacing: 4) {
                Text(DayEventStore.language == "tr" ? "RESMİ BORÇ SENEDİ & ZAFER MAKBUZU" : "OFFICIAL VICTORY VOUCHER")
                    .font(.system(size: 11, weight: .black, design: .monospaced))
                    .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.6))
                    .tracking(1.5)

                Text("№ WHD-\(bet.id.prefix(6).uppercased())")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color(hex: colors.accent))
            }

            Divider().background(Color(hex: colors.ink).opacity(0.12))

            // Details
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(DayEventStore.language == "tr" ? "İDDİA KONUSU" : "SUBJECT")
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                        .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.5))
                    Text(bet.title)
                        .appFont(size: 16, weight: .bold, relativeTo: .body)
                        .foregroundStyle(Color(hex: colors.ink))
                }

                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(DayEventStore.language == "tr" ? "KAZANAN" : "WINNER")
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                            .foregroundStyle(Color(hex: colors.accent))
                        Text(bet.winner ?? "-")
                            .appFont(size: 18, weight: .black, relativeTo: .headline)
                            .foregroundStyle(Color(hex: colors.ink))
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(DayEventStore.language == "tr" ? "BORÇLU" : "LOSER")
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                            .foregroundStyle(Color.red.opacity(0.8))
                        Text(bet.loser() ?? "-")
                            .appFont(size: 16, weight: .bold, relativeTo: .headline)
                            .foregroundStyle(Color(hex: colors.ink))
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(DayEventStore.language == "tr" ? "ÖDENECEK BEDEL" : "THE STAKE")
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                        .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.5))
                    Text(bet.stake)
                        .appFont(size: 15, weight: .bold, relativeTo: .body)
                        .foregroundStyle(Color(hex: colors.ink))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider().background(Color(hex: colors.ink).opacity(0.12))

            // Seal Stamp
            HStack {
                Text("🔏")
                    .font(.system(size: 20))
                VStack(alignment: .leading, spacing: 1) {
                    Text(DayEventStore.language == "tr" ? "WHADAY MÜHRÜ İLE TASDİKLENMİŞTİR" : "CERTIFIED BY WHADAY")
                        .font(.system(size: 9, weight: .black, design: .monospaced))
                        .foregroundStyle(Color(hex: colors.ink))
                    Text("\(bet.formattedTargetDate)")
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.6))
                }
                Spacer()
            }
            .padding(10)
            .background(Color(hex: colors.accent).opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(22)
        .background(Color(hex: colors.backdropRaised).opacity(0.98))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color(hex: colors.ink).opacity(0.16), lineWidth: 1.5)
        )
    }
}

private struct ReceiptShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
