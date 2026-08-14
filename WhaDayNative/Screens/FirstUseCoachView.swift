import SwiftUI

struct FirstUseCoachView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let step: Int
    let colors: ThemeColors
    let onNext: () -> Void
    let onDismiss: () -> Void

    private var content: (symbol: String, title: String, body: String) {
        let tr = DayEventStore.language == "tr"
        switch step {
        case 0:
            return (
                "hand.draw.fill",
                tr ? "Günler arasında kaydır" : "Swipe through the days",
                tr ? "Bugünün bahanesinden komşu günlere tek hareketle geç." : "Move from today's reason to nearby days in one gesture."
            )
        case 1:
            return (
                "calendar.badge.plus",
                tr ? "Takvimde seç ve kaydet" : "Discover and save",
                tr ? "Takvim simgesi haftalık seçimleri, aramayı ve kayıtlarını açar." : "The calendar opens weekly picks, search and your saved days."
            )
        default:
            return (
                "paperplane.fill",
                tr ? "Kişiye göre gönder" : "Make it personal",
                tr ? "Alttaki düğme kartı mesaj veya Story formatında hazırlar." : "The button below prepares a message or Story card."
            )
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: content.symbol)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(Color(hex: colors.ink))
                .frame(width: 44, height: 44)
                .background(Color(hex: colors.secondary))
                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text("\(step + 1) / 3 · \(content.title)")
                    .appFont(size: 14, weight: .black, relativeTo: .headline)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? 3 : 1)
                    .minimumScaleFactor(0.78)
                Text(content.body)
                    .appFont(size: 11, weight: .semibold, relativeTo: .caption)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? 5 : 2)
                    .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.66))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: onNext) {
                Image(systemName: step == 2 ? "checkmark" : "chevron.right")
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(Color(hex: colors.ink))
                    .frame(width: 40, height: 40)
                    .background(Color(hex: colors.accent))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .minimumAccessibleTarget()
            .accessibilityLabel(step == 2
                                ? (DayEventStore.language == "tr" ? "İpuçlarını bitir" : "Finish tips")
                                : (DayEventStore.language == "tr" ? "Sonraki ipucu" : "Next tip"))
        }
        .foregroundStyle(Color(hex: colors.onBackdrop))
        .padding(14)
        .background(Color(hex: colors.backdropRaised).opacity(0.97))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color(hex: colors.accent).opacity(0.34), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.30), radius: 24, x: 0, y: 12)
        .overlay(alignment: .topTrailing) {
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 9, weight: .black))
                    .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.68))
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .offset(x: 5, y: -7)
            .accessibilityLabel(DayEventStore.language == "tr" ? "İpuçlarını kapat" : "Dismiss tips")
        }
        .accessibilityElement(children: .contain)
    }
}
