import SwiftUI

enum ShareCardFormat {
    case story
    case message

    var canvasSize: CGSize {
        switch self {
        case .story: return CGSize(width: 360, height: 640)
        case .message: return CGSize(width: 360, height: 450)
        }
    }
}

struct ShareCardView: View {
    let event: DayEvent?
    let colors: ThemeColors
    let format: ShareCardFormat

    private var editorial: EditorialContent? { event.map(EditorialContent.forEvent) }

    private var dateText: String {
        var components = DateComponents()
        components.month = event?.month ?? 1
        components.day = event?.day ?? 1
        components.year = Calendar.current.component(.year, from: Date())
        guard let date = Calendar.current.date(from: components) else { return "" }
        let formatter = DateFormatter()
        formatter.locale = DayEventStore.dateLocale
        formatter.setLocalizedDateFormatFromTemplate("d MMMM")
        return formatter.string(from: date)
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: colors.backdrop), Color(hex: colors.backdropRaised)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            glowField
            fineGrid

            VStack(alignment: .leading, spacing: 0) {
                cardHeader
                Spacer(minLength: format == .story ? 34 : 20)
                vividCard
                Spacer(minLength: format == .story ? 28 : 18)
                cardFooter
            }
            .padding(format == .story ? 28 : 24)
        }
        .frame(width: format.canvasSize.width, height: format.canvasSize.height)
        .clipped()
    }

    private var cardHeader: some View {
        HStack(spacing: 8) {
            BrandMark(color: Color(hex: colors.secondary))
                .frame(width: 25, height: 25)
                .scaleEffect(0.58)
            Text("WHADAY")
                .font(.system(size: 14, weight: .black, design: .rounded))
                .tracking(1)

            Spacer()

            Text(dateText.uppercased())
                .font(.system(size: 10, weight: .black, design: .rounded))
                .tracking(1)
                .opacity(0.62)
        }
        .foregroundStyle(Color(hex: colors.onBackdrop))
    }

    private var vividCard: some View {
        VStack(alignment: .leading, spacing: format == .story ? 19 : 13) {
            HStack(alignment: .center) {
                Text(editorial?.eyebrow ?? "WHADAY")
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .tracking(1.3)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(Color(hex: colors.ink).opacity(0.88))
                    .foregroundStyle(Color(hex: colors.onBackdrop))
                    .clipShape(Capsule())

                Spacer()

                Text(event.map(EditorialSymbol.forEvent) ?? "✦")
                    .font(.system(size: format == .story ? 48 : 38))
                    .rotationEffect(.degrees(5))
            }

            Text(event?.title ?? Strings.noEventTitle)
                .font(.system(size: titleSize, weight: .black, design: .rounded))
                .tracking(-1.6)
                .foregroundStyle(Color(hex: colors.ink))
                .lineLimit(format == .story ? 5 : 4)
                .minimumScaleFactor(0.58)
                .fixedSize(horizontal: false, vertical: true)

            Rectangle()
                .fill(Color(hex: colors.ink).opacity(0.7))
                .frame(height: 1.5)

            Text(editorial?.fact ?? Strings.noEventDesc)
                .font(.system(size: format == .story ? 16 : 13, weight: .semibold, design: .rounded))
                .lineSpacing(format == .story ? 3 : 2)
                .foregroundStyle(Color(hex: colors.ink).opacity(0.78))
                .lineLimit(format == .story ? 5 : 4)
                .minimumScaleFactor(0.72)
        }
        .padding(format == .story ? 24 : 20)
        .background(
            LinearGradient(
                colors: [Color(hex: colors.paper), Color(hex: colors.blob1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
        )
        .shadow(color: Color(hex: colors.accent).opacity(0.30), radius: 28, x: 0, y: 16)
    }

    private var cardFooter: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(editorial?.prompt ?? Strings.shareOnStory)
                .font(.system(size: format == .story ? 16 : 13, weight: .black, design: .rounded))
                .foregroundStyle(Color(hex: colors.onBackdrop))
                .lineLimit(2)

            HStack(spacing: 7) {
                Capsule()
                    .fill(Color(hex: colors.secondary))
                    .frame(width: 22, height: 4)
                Text(footerLabel)
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .tracking(0.8)
                    .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.52))
            }
        }
    }

    private var footerLabel: String {
        let isRemembrance = editorial?.tone == .remembrance
        if DayEventStore.language == "tr" {
            return isRemembrance ? "GÜNÜN NOTU" : "GÜNÜN BAHANESİ"
        }
        return isRemembrance ? "TODAY'S NOTE" : "TODAY'S EXCUSE"
    }

    private var glowField: some View {
        ZStack {
            Circle()
                .fill(Color(hex: colors.accent).opacity(0.30))
                .frame(width: format == .story ? 310 : 240)
                .blur(radius: 55)
                .offset(x: 145, y: format == .story ? -260 : -180)
            Circle()
                .fill(Color(hex: colors.secondary).opacity(0.16))
                .frame(width: 230)
                .blur(radius: 65)
                .offset(x: -155, y: format == .story ? 270 : 195)
        }
    }

    private var fineGrid: some View {
        Canvas { context, size in
            let spacing: CGFloat = 24
            for x in stride(from: 0, through: size.width, by: spacing) {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(path, with: .color(.white.opacity(0.035)), lineWidth: 0.5)
            }
            for y in stride(from: 0, through: size.height, by: spacing) {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(path, with: .color(.white.opacity(0.035)), lineWidth: 0.5)
            }
        }
    }

    private var titleSize: CGFloat {
        let count = event?.title.count ?? 0
        if format == .message {
            if count > 70 { return 26 }
            if count > 42 { return 30 }
            return 37
        }
        if count > 70 { return 31 }
        if count > 42 { return 37 }
        return 47
    }
}
