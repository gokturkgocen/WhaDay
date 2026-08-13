import SwiftUI
import UIKit

struct ActionButtons: View {
    let prompt: String
    let storyImage: UIImage?
    let messageImage: UIImage?
    let accentColor: Color
    let inkColor: Color
    let onBackdropColor: Color

    @State private var activeShare: ShareDestination?

    var body: some View {
        VStack(spacing: 10) {
            Button {
                Haptics.triggerMedium()
                activeShare = .message
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "paperplane.fill")
                    Text(prompt)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                    Spacer(minLength: 4)
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 13, weight: .black))
                }
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundStyle(inkColor)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: accentColor.opacity(0.22), radius: 18, x: 0, y: 9)
            }
            .disabled(messageImage == nil)

            Button {
                Haptics.triggerLight()
                activeShare = .story
            } label: {
                HStack(spacing: 9) {
                    Image(systemName: "rectangle.portrait.on.rectangle.portrait")
                    Text(DayEventStore.language == "tr" ? "Story için hazırla" : "Create a Story")
                }
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(onBackdropColor)
                .frame(maxWidth: .infinity, minHeight: 43)
                .background(Color.white.opacity(0.07))
                .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 17, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
                )
            }
            .disabled(storyImage == nil)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .sheet(item: $activeShare) { destination in
            ActivityShareView(items: shareItems(for: destination))
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    private func shareItems(for destination: ShareDestination) -> [Any] {
        switch destination {
        case .story:
            if let storyImage { return [storyImage] }
            return []
        case .message:
            if let messageImage { return [messageImage] }
            return []
        }
    }
}

private enum ShareDestination: String, Identifiable {
    case story
    case message

    var id: String { rawValue }
}

private struct ActivityShareView: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
