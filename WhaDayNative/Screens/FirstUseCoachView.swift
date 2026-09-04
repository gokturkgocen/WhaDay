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
                "arrow.left.and.right",
                tr ? "Günler arasında kaydır" : "Swipe through the days",
                tr ? "Önceki ve sonraki günlere tek hareketle geç." : "Move to the previous or next day in one gesture."
            )
        case 1:
            return (
                "calendar.badge.plus",
                tr ? "Takvimde seç ve kaydet" : "Discover and save",
                tr ? "Takvim simgesi haftalık seçimleri, aramayı ve kayıtlarını açar." : "The calendar opens weekly picks, search and your saved days."
            )
        default:
            return (
                "square.and.arrow.up",
                tr ? "Kartı paylaş" : "Share the card",
                tr ? "Kartı mesaj veya Story ölçüsünde hazırla." : "Prepare the card for a message or Story."
            )
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 7) {
                    Text(String(format: "%02d", step + 1))
                        .appFont(size: 10, weight: .medium, design: .monospaced, relativeTo: .caption)
                        .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.42))
                    Text(content.title)
                        .appFont(size: 14, weight: .semibold, relativeTo: .headline)
                }
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? 3 : 1)
                    .minimumScaleFactor(0.78)
                Text(content.body)
                    .appFont(size: 11, weight: .regular, relativeTo: .caption)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? 5 : 2)
                    .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.56))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: onNext) {
                Image(systemName: step == 2 ? "checkmark" : "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color(hex: colors.paper))
                    .frame(width: 40, height: 40)
                    .background(Color(hex: colors.ink))
                    .clipShape(Rectangle())
            }
            .buttonStyle(.plain)
            .minimumAccessibleTarget()
            .accessibilityLabel(step == 2
                                ? (DayEventStore.language == "tr" ? "İpuçlarını bitir" : "Finish tips")
                                : (DayEventStore.language == "tr" ? "Sonraki ipucu" : "Next tip"))
        }
        .foregroundStyle(Color(hex: colors.onBackdrop))
        .padding(14)
        .background(Color(hex: colors.backdropRaised))
        .clipShape(Rectangle())
        .overlay(
            Rectangle()
                .strokeBorder(Color(hex: colors.ink).opacity(0.10), lineWidth: 1)
        )
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
