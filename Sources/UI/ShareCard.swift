import SwiftUI
import UIKit

/// Renders a branded "look how good I did" card. With no UA budget, this image is the
/// marketing department — it must be a shareable picture, not a number (see DESIGN.md).
enum ShareCard {
    @MainActor
    static func render(height: Int, tower: UIImage?) -> UIImage {
        let card = CardView(height: height, tower: tower)
        let renderer = ImageRenderer(content: card)
        renderer.scale = 3
        return renderer.uiImage ?? UIImage()
    }

    private struct CardView: View {
        let height: Int
        let tower: UIImage?
        var body: some View {
            ZStack {
                Theme.parchment
                if let tower {
                    Image(uiImage: tower).resizable().aspectRatio(contentMode: .fill)
                        .frame(width: 320, height: 440).clipped().opacity(0.96)
                }
                Image(Art.shareFrame).resizable()
                VStack {
                    Spacer()
                    Text("\(height)").font(Theme.display(76)).foregroundColor(Theme.ink)
                    Text("FLOORS").font(Theme.display(22)).foregroundColor(Theme.copper)
                    Text("can you out-build me?").font(Theme.body(15)).foregroundColor(Theme.brassDk)
                    Text("TEETER").font(Theme.display(18)).foregroundColor(Theme.ink).padding(.top, 6)
                    Spacer().frame(height: 26)
                }
            }
            .frame(width: 360, height: 506)
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}
