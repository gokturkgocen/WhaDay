import SwiftUI

/// The rasterized 1080x1920 story card shared to Instagram/etc. Rendered offscreen via
/// `ShareCardRenderer`, never displayed live.
struct ShareCardView: View {
    let event: DayEvent?
    let colors: ThemeColors

    private var dateText: String {
        var components = DateComponents()
        components.month = event?.month ?? 1
        components.day = event?.day ?? 1
        components.year = Calendar.current.component(.year, from: Date())
        guard let date = Calendar.current.date(from: components) else { return "" }

        let formatter = DateFormatter()
        formatter.locale = DayEventStore.dateLocale
        formatter.setLocalizedDateFormatFromTemplate("MMMM d")
        return formatter.string(from: date)
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: colors.gradient.map(Color.init(hex:)), startPoint: .top, endPoint: .bottom)

            Circle().fill(Color(hex: colors.blob1)).opacity(0.3)
                .frame(width: 420, height: 420)
                .position(x: 1080 - 80 - 210, y: -100 + 210)

            Circle().fill(Color(hex: colors.blob2)).opacity(0.3)
                .frame(width: 300, height: 300)
                .position(x: -60 + 150, y: 1920 - 200 - 150)

            Circle().fill(Color(hex: colors.blob3)).opacity(0.3)
                .frame(width: 220, height: 220)
                .position(x: 1080 - 60 - 110, y: 1920 + 40 - 110)

            VStack(spacing: 0) {
                Text(event?.emoji ?? "✨")
                    .font(.system(size: 130))
                    .padding(.bottom, 36)

                Text(event?.title ?? Strings.noEventTitle)
                    .font(.system(size: 80, weight: .heavy))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 28)

                Text(event?.description ?? Strings.noEventDesc)
                    .font(.system(size: 38))
                    .foregroundStyle(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 80)
            .padding(.horizontal, 56)
            .background(Color.white.opacity(0.08))
            .overlay(RoundedRectangle(cornerRadius: 50).strokeBorder(Color.white.opacity(0.2), lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 50))
            .padding(.horizontal, 36)

            VStack(spacing: 10) {
                Spacer()
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(hex: colors.accent))
                    .frame(width: 56, height: 56)
                    .overlay(Text("W").font(.system(size: 30, weight: .black)).foregroundStyle(.white))
                Text("WHADAY")
                    .font(.system(size: 30, weight: .heavy))
                    .foregroundStyle(.white.opacity(0.55))
                    .tracking(2)
                Text(dateText)
                    .font(.system(size: 22))
                    .foregroundStyle(.white.opacity(0.3))
                Spacer().frame(height: 80)
            }
        }
        .frame(width: 1080, height: 1920)
    }
}
