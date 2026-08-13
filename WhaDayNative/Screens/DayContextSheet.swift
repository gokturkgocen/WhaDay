import SwiftUI

struct DayContextSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var personalLibrary: PersonalDayLibrary

    let event: DayEvent
    let colors: ThemeColors

    private var editorial: EditorialContent { EditorialContent.forEvent(event) }
    private var provenance: DayProvenance { DayProvenance.forEvent(event) }

    var body: some View {
        ZStack {
            EditorialBackground(colors: colors, elapsed: 0)

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    identityCard
                    contextCard
                    saveCard
                    sourceCard
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .scrollIndicators(.hidden)
        }
    }

    private var saveCard: some View {
        Button {
            Haptics.triggerMedium()
            personalLibrary.toggle(event)
        } label: {
            HStack(spacing: 13) {
                Image(systemName: personalLibrary.isSaved(event) ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 19, weight: .black))
                    .foregroundStyle(Color(hex: colors.ink))
                    .frame(width: 44, height: 44)
                    .background(Color(hex: colors.accent))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 3) {
                    Text(personalLibrary.isSaved(event)
                         ? (DayEventStore.language == "tr" ? "Sonra göndermek için kaydedildi" : "Saved to send later")
                         : (DayEventStore.language == "tr" ? "Sonra göndermek için kaydet" : "Save to send later"))
                        .font(.system(size: 14, weight: .black, design: .rounded))

                    Text(DayEventStore.language == "tr"
                         ? "Yalnızca bu cihazda saklanır."
                         : "Stored only on this device.")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .opacity(0.56)
                }

                Spacer()

                Image(systemName: personalLibrary.isSaved(event) ? "checkmark" : "plus")
                    .font(.system(size: 13, weight: .black))
            }
        }
        .buttonStyle(.plain)
        .contextCard(colors: colors)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(DayEventStore.language == "tr" ? "Neden bugün?" : "Why today?")
                    .font(.system(size: 27, weight: .black, design: .rounded))
                    .tracking(-0.8)
                Text(event.title)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.58))
                    .lineLimit(2)
            }

            Spacer()

            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .black))
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .foregroundStyle(Color(hex: colors.onBackdrop))
        .padding(.top, 8)
    }

    private var identityCard: some View {
        HStack(spacing: 13) {
            Image(systemName: provenance.isOfficial ? "checkmark.seal.fill" : provenance.kind == .cultural ? "globe.europe.africa.fill" : "sparkles")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color(hex: colors.ink))
                .frame(width: 48, height: 48)
                .background(Color(hex: colors.accent))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(provenance.label)
                    .font(.system(size: 15, weight: .black, design: .rounded))
                Text(provenance.isOfficial
                     ? (DayEventStore.language == "tr" ? "Birincil kurum takvimiyle eşleşiyor" : "Matches a primary institution calendar")
                     : (DayEventStore.language == "tr" ? "Statüsü açıkça belirtilir" : "Its status is stated clearly"))
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .opacity(0.58)
            }
            Spacer()
        }
        .contextCard(colors: colors)
    }

    private var contextCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(DayEventStore.language == "tr" ? "WhaDay notu" : "WhaDay note", systemImage: "text.quote")
                .font(.system(size: 14, weight: .black, design: .rounded))

            Text(editorial.fact)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .lineSpacing(4)
                .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.86))
        }
        .contextCard(colors: colors)
    }

    private var sourceCard: some View {
        VStack(alignment: .leading, spacing: 13) {
            Label(DayEventStore.language == "tr" ? "Statü ve kaynak" : "Status and source", systemImage: "link")
                .font(.system(size: 14, weight: .black, design: .rounded))

            Text(provenance.explanation)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .lineSpacing(3)
                .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.66))

            if let name = provenance.sourceName, let url = provenance.sourceURL {
                Link(destination: url) {
                    HStack {
                        Text(name)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                    }
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(Color(hex: colors.ink))
                    .padding(.horizontal, 15)
                    .frame(height: 44)
                    .background(Color(hex: colors.accent))
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                }
            }
        }
        .contextCard(colors: colors)
    }
}

private extension View {
    func contextCard(colors: ThemeColors) -> some View {
        self
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(Color(hex: colors.onBackdrop))
            .background(Color(hex: colors.backdropRaised).opacity(0.94))
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.11), lineWidth: 1)
            )
    }
}
