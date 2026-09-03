import SwiftUI

struct DayContextSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var personalLibrary: PersonalDayLibrary
    @EnvironmentObject private var customDayStore: CustomDayStore

    let event: DayEvent
    let colors: ThemeColors

    @State private var showingCustomEditor = false
    @State private var showingShareSheet = false

    private var editorial: EditorialContent { EditorialContent.forEvent(event) }
    private var provenance: DayProvenance { DayProvenance.forEvent(event) }

    var body: some View {
        ZStack {
            EditorialBackground(colors: colors, elapsed: 0)

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    soundtrackCard
                    betCard
                    timeCapsuleCard
                    customDayCard
                    contextCard
                    saveCard
                    editorialFooter
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .scrollIndicators(.hidden)
        }
        .sheet(isPresented: $showingCustomEditor) {
            CustomDayEditorSheet(
                dayID: event.id,
                month: event.month,
                day: event.day,
                colors: colors,
                existingRecord: customDayStore.customDay(for: event.id),
                defaultEvent: DayEventStore.event(id: event.id)
            )
            .presentationDetents([.large])
        }
        .sheet(isPresented: $showingShareSheet) {
            if let custom = customDayStore.customDay(for: event.id), let url = custom.webShareURL() {
                CustomShareActivityView(items: [
                    "\(custom.emoji) \(custom.title)\n\(custom.description)\n\nBu günü WhaDay takvimine ekle: \(url.absoluteString)"
                ])
                .presentationDetents([.medium, .large])
            }
        }
    }

    private var customDayCard: some View {
        Group {
            if customDayStore.isCustom(dayID: event.id) {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Color(hex: colors.ink))
                            .frame(width: 40, height: 40)
                            .background(Color(hex: colors.accent))
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 2) {
                            Text(DayEventStore.language == "tr" ? "Kişisel Özel Günün" : "Personal Custom Day")
                                .appFont(size: 14, weight: .black, relativeTo: .headline)
                            Text(DayEventStore.language == "tr" ? "Bu günü sen belirledin veya arkadaşından ekledin." : "Defined by you or added from a friend.")
                                .appFont(size: 11, weight: .medium, relativeTo: .caption)
                                .opacity(0.6)
                        }
                    }

                    HStack(spacing: 8) {
                        Button {
                            showingShareSheet = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 12, weight: .bold))
                                Text(DayEventStore.language == "tr" ? "Paylaş" : "Share")
                                    .appFont(size: 12, weight: .bold, relativeTo: .caption)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color(hex: colors.accent))
                            .foregroundStyle(Color(hex: colors.ink))
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)

                        Button {
                            showingCustomEditor = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 12, weight: .bold))
                                Text(DayEventStore.language == "tr" ? "Düzenle" : "Edit")
                                    .appFont(size: 12, weight: .bold, relativeTo: .caption)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color(hex: colors.ink).opacity(0.06))
                            .foregroundStyle(Color(hex: colors.onBackdrop))
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)

                        Spacer()

                        Button {
                            customDayStore.remove(for: event.id)
                        } label: {
                            Text(DayEventStore.language == "tr" ? "Orijinale Dön" : "Reset")
                                .appFont(size: 11, weight: .semibold, relativeTo: .caption2)
                                .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.5))
                                .underline()
                        }
                        .buttonStyle(.plain)
                    }
                }
                .contextCard(colors: colors)
            } else {
                Button {
                    Haptics.triggerLight()
                    showingCustomEditor = true
                } label: {
                    HStack(spacing: 13) {
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 18, weight: .black))
                            .foregroundStyle(Color(hex: colors.ink))
                            .frame(width: 44, height: 44)
                            .background(Color(hex: colors.accent))
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 3) {
                            Text(DayEventStore.language == "tr" ? "Bu Günü Özelleştir" : "Personalize This Day")
                                .appFont(size: 14, weight: .black, relativeTo: .headline)

                            Text(DayEventStore.language == "tr"
                                 ? "Doğum gününü veya özel bir anını ata, arkadaşlarına yolla."
                                 : "Set your birthday or anniversary and share it.")
                                .appFont(size: 11, weight: .semibold, relativeTo: .caption)
                                .opacity(0.56)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .black))
                            .opacity(0.4)
                    }
                }
                .buttonStyle(.plain)
                .contextCard(colors: colors)
            }
        }
    }

    private var soundtrackCard: some View {
        SoundtrackSectionView(
            dayID: event.id,
            colors: colors
        )
    }

    private var betCard: some View {
        BetSectionView(
            dayID: event.id,
            targetMonth: event.month,
            targetDay: event.day,
            colors: colors
        )
    }

    private var timeCapsuleCard: some View {
        TimeCapsuleSection(
            capsuleID: event.id,
            targetMonth: event.month,
            targetDay: event.day,
            dayTitle: event.title,
            colors: colors
        )
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
                        .appFont(size: 14, weight: .black, relativeTo: .headline)

                    Text(DayEventStore.language == "tr"
                         ? "Yalnızca bu cihazda saklanır."
                         : "Stored only on this device.")
                        .appFont(size: 11, weight: .semibold, relativeTo: .caption)
                        .opacity(0.56)
                }

                Spacer()

                Image(systemName: personalLibrary.isSaved(event) ? "checkmark" : "plus")
                    .font(.system(size: 13, weight: .black))
            }
        }
        .buttonStyle(.plain)
        .contextCard(colors: colors)
        .accessibilityValue(personalLibrary.isSaved(event) ? AccessibilityCopy.selected : "")
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(DayEventStore.language == "tr" ? "Günün Alanı" : "Day Club")
                    .appFont(size: 27, weight: .black, relativeTo: .title)
                    .tracking(-0.8)
                Text(event.title)
                    .appFont(size: 13, weight: .bold, relativeTo: .subheadline)
                    .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.58))
                    .lineLimit(2)
            }

            Spacer()

            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .black))
                    .frame(width: 44, height: 44)
                    .background(Color(hex: colors.ink).opacity(0.06))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(DayEventStore.language == "tr" ? "Kapat" : "Close")
        }
        .foregroundStyle(Color(hex: colors.onBackdrop))
        .padding(.top, 8)
    }

    private var contextCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(DayEventStore.language == "tr" ? "WhaDay notu" : "WhaDay note", systemImage: "text.quote")
                .appFont(size: 14, weight: .black, relativeTo: .headline)

            Text(editorial.fact)
                .appFont(size: 18, weight: .bold, relativeTo: .body)
                .lineSpacing(4)
                .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.86))
        }
        .contextCard(colors: colors)
    }

    private var editorialFooter: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: provenance.isOfficial ? "checkmark.seal.fill" : "globe.europe.africa.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Color(hex: colors.accent))

                Text(DayEventStore.language == "tr" ? "EDİTORYAL KÜNYE" : "EDITORIAL PROVENANCE")
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                    .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.5))
                    .tracking(1.2)
            }

            Text(provenance.explanation)
                .appFont(size: 12, weight: .medium, relativeTo: .caption)
                .lineSpacing(2)
                .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.6))

            if let name = provenance.sourceName, let url = provenance.sourceURL {
                Link(destination: url) {
                    HStack(spacing: 4) {
                        Text(name)
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 9, weight: .bold))
                    }
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color(hex: colors.accent))
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: colors.backdropRaised).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct ContextCardModifier: ViewModifier {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var contrast

    let colors: ThemeColors

    func body(content: Content) -> some View {
        content
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(Color(hex: colors.onBackdrop))
            .background(Color(hex: colors.backdropRaised).opacity(reduceTransparency ? 1 : 0.94))
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(Color(hex: colors.ink).opacity(contrast == .increased ? 0.34 : 0.11), lineWidth: contrast == .increased ? 2 : 1)
            )
    }
}

private extension View {
    func contextCard(colors: ThemeColors) -> some View {
        modifier(ContextCardModifier(colors: colors))
    }
}

private struct CustomShareActivityView: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
