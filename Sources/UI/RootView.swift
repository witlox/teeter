import SwiftUI
import SpriteKit

struct RootView: View {
    @EnvironmentObject var model: GameViewModel
    @State private var scene: GameScene?

    var body: some View {
        GeometryReader { geo in
            ZStack {
                if let scene {
                    SpriteView(scene: scene, options: [.ignoresSiblingOrder])
                        .ignoresSafeArea()
                } else {
                    Theme.parchment.ignoresSafeArea()
                }

                switch model.phase {
                case .menu:
                    MenuView()
                case .playing:
                    HUDView()
                case .toppling:
                    HUDView()
                    CatchOfferView()
                case .gameOver:
                    GameOverView()
                case .cashedOut:
                    CashOutView()
                }
            }
            .onAppear { if scene == nil { build(size: geo.size) } }
        }
    }

    private func build(size: CGSize) {
        let s = GameScene(size: size)
        s.scaleMode = .resizeFill
        s.model = model
        model.scene = s
        scene = s
    }
}

/// Brass plate button using the generated art as the surface.
struct BrassButton: View {
    let title: String
    var subtitle: String? = nil
    var wide: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: { Haptics.light(); action() }) {
            ZStack {
                Image(wide ? Art.btn : Art.btnSmall)
                    .resizable()
                    .frame(width: wide ? 300 : 150, height: 92)
                VStack(spacing: 1) {
                    Text(title).font(Theme.display(22)).foregroundColor(Theme.ink)
                    if let subtitle {
                        Text(subtitle).font(Theme.body(12)).foregroundColor(Theme.brassDk)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
}

struct MenuView: View {
    @EnvironmentObject var model: GameViewModel
    @State private var showLeaderboard = false
    var body: some View {
        VStack(spacing: 18) {
            Spacer()
            Text("TEETER")
                .font(Theme.display(64))
                .foregroundColor(Theme.ink)
                .shadow(color: Theme.brassHi, radius: 0, x: 2, y: 2)
            Text("stack it. bank it. or lose the lot.")
                .font(Theme.body(15)).foregroundColor(Theme.brassDk)

            if model.best > 0 {
                Text("best tower — \(model.best) floors")
                    .font(Theme.body(16)).foregroundColor(Theme.copper).padding(.top, 4)
            }
            Spacer()
            BrassButton(title: "BUILD") { model.startRun() }
            BrassButton(title: "LEADERBOARD", wide: false) { showLeaderboard = true }
            Text("\(Tuning.catchesPerRun) saves per run")
                .font(Theme.body(13)).foregroundColor(Theme.patina)
            Spacer().frame(height: 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $showLeaderboard) {
            LeaderboardSheet(isPresented: $showLeaderboard).ignoresSafeArea()
        }
    }
}
