import SwiftUI

struct SoundtrackSectionView: View {
    @EnvironmentObject private var soundtrackStore: DaySoundtrackStore

    let dayID: String
    let colors: ThemeColors

    @State private var showingEditSheet = false
    @State private var isSpinning = false

    private var soundtrack: DaySoundtrack? {
        soundtrackStore.soundtrack(for: dayID)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 6) {
                    Text("🎵")
                        .font(.system(size: 13))
                    Text(DayEventStore.language == "tr" ? "GÜNÜN ŞARKISI" : "SOUNDTRACK")
                        .appFont(size: 12, weight: .black, relativeTo: .caption)
                        .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.6))
                        .tracking(1.2)
                }

                Spacer()

                Button {
                    Haptics.triggerLight()
                    showingEditSheet = true
                } label: {
                    Text(soundtrack == nil
                         ? (DayEventStore.language == "tr" ? "+ Şarkı Ekle" : "+ Add Song")
                         : (DayEventStore.language == "tr" ? "Değiştir" : "Change"))
                        .appFont(size: 11, weight: .bold, relativeTo: .caption2)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color(hex: colors.ink).opacity(0.06))
                        .foregroundStyle(Color(hex: colors.onBackdrop))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }

            if let st = soundtrack {
                soundtrackCard(st)
            } else {
                emptySoundtrackButton
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditSoundtrackSheet(
                dayID: dayID,
                existing: soundtrack,
                colors: colors
            )
            .presentationDetents([.medium])
        }
    }

    private func soundtrackCard(_ st: DaySoundtrack) -> some View {
        HStack(spacing: 14) {
            // Spinning Vinyl Disc
            ZStack {
                Circle()
                    .fill(Color(hex: colors.ink))
                    .frame(width: 44, height: 44)

                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
                    .frame(width: 32, height: 32)

                Circle()
                    .fill(Color(hex: colors.accent))
                    .frame(width: 14, height: 14)
            }
            .rotationEffect(.degrees(isSpinning ? 360 : 0))
            .animation(Animation.linear(duration: 4).repeatForever(autoreverses: false), value: isSpinning)
            .onAppear { isSpinning = true }

            VStack(alignment: .leading, spacing: 2) {
                Text(st.trackTitle)
                    .appFont(size: 15, weight: .bold, relativeTo: .headline)
                    .foregroundStyle(Color(hex: colors.ink))
                    .lineLimit(1)

                Text(st.artistName)
                    .appFont(size: 12, weight: .medium, relativeTo: .caption)
                    .foregroundStyle(Color(hex: colors.onBackdrop).opacity(0.7))
                    .lineLimit(1)
            }

            Spacer()

            if let url = st.targetPlaybackURL() {
                Link(destination: url) {
                    HStack(spacing: 4) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 11, weight: .black))
                        Text(DayEventStore.language == "tr" ? "Dinle" : "Play")
                            .appFont(size: 12, weight: .black, relativeTo: .caption)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(hex: colors.accent))
                    .foregroundStyle(Color(hex: colors.ink))
                    .clipShape(Capsule())
                }
            }
        }
        .padding(14)
        .background(Color(hex: colors.backdropRaised).opacity(0.94))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var emptySoundtrackButton: some View {
        Button {
            Haptics.triggerLight()
            showingEditSheet = true
        } label: {
            HStack(spacing: 10) {
                Text("📻")
                    .font(.system(size: 20))
                Text(DayEventStore.language == "tr" ? "Bu güne bir şarkı iliştir" : "Attach a soundtrack to this day")
                    .appFont(size: 13, weight: .bold, relativeTo: .subheadline)
                    .foregroundStyle(Color(hex: colors.ink))
                Spacer()
            }
            .padding(12)
            .background(Color(hex: colors.backdropRaised).opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct EditSoundtrackSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: DaySoundtrackStore

    let dayID: String
    let existing: DaySoundtrack?
    let colors: ThemeColors

    @State private var trackTitle: String = ""
    @State private var artistName: String = ""
    @State private var musicURL: String = ""
    @State private var addedBy: String = ""

    private var isValid: Bool {
        !trackTitle.trimmingCharacters(in: .whitespaces).isEmpty &&
        !artistName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        ZStack {
            EditorialBackground(colors: colors, elapsed: 0)

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(DayEventStore.language == "tr" ? "Günün Şarkısı" : "Day's Soundtrack")
                        .appFont(size: 20, weight: .black, relativeTo: .title3)
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .frame(width: 36, height: 36)
                            .background(Color(hex: colors.ink).opacity(0.06))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 8)

                VStack(spacing: 10) {
                    TextField(DayEventStore.language == "tr" ? "Şarkı Adı (Örn: One More Time)" : "Song Title", text: $trackTitle)
                        .padding(12)
                        .background(Color(hex: colors.backdropRaised))
                        .clipShape(RoundedRectangle(cornerRadius: 14))

                    TextField(DayEventStore.language == "tr" ? "Sanatçı (Örn: Daft Punk)" : "Artist Name", text: $artistName)
                        .padding(12)
                        .background(Color(hex: colors.backdropRaised))
                        .clipShape(RoundedRectangle(cornerRadius: 14))

                    TextField(DayEventStore.language == "tr" ? "Spotify / Apple Music Linki (İsteğe bağlı)" : "Music Link (Optional)", text: $musicURL)
                        .padding(12)
                        .background(Color(hex: colors.backdropRaised))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                Spacer()

                Button {
                    store.setSoundtrack(
                        dayID: dayID,
                        trackTitle: trackTitle,
                        artistName: artistName,
                        musicURL: musicURL,
                        addedBy: addedBy
                    )
                    dismiss()
                } label: {
                    Text(DayEventStore.language == "tr" ? "Kaydet ve İliştir" : "Save Soundtrack")
                        .appFont(size: 15, weight: .black, relativeTo: .headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(isValid ? Color(hex: colors.accent) : Color(hex: colors.ink).opacity(0.1))
                        .foregroundStyle(isValid ? Color(hex: colors.ink) : Color(hex: colors.onBackdrop).opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(!isValid)
                .buttonStyle(.plain)
            }
            .padding(20)
        }
        .onAppear {
            if let st = existing {
                trackTitle = st.trackTitle
                artistName = st.artistName
                musicURL = st.musicURL ?? ""
                addedBy = st.addedBy
            }
        }
    }
}
