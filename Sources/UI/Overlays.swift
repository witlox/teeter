import SwiftUI

/// Fired the instant the tower passes the stability threshold. Physics is in slow-mo
/// behind this, so the player sees the teeter. Two branches:
///   - a save is available (free, or owned from the unlock) -> "CATCH IT"
///   - out of saves and not yet unlocked -> the high-intent unlock offer
///     ("I was that close"): buying both unlocks 3/run AND catches this tower.
struct CatchOfferView: View {
    @EnvironmentObject var model: GameViewModel
    var body: some View {
        ZStack {
            Theme.ink.opacity(0.18).ignoresSafeArea()
            VStack(spacing: 14) {
                Spacer()
                Text("IT'S GOING!")
                    .font(Theme.display(34)).foregroundColor(Theme.rust)
                Text("\(model.height) floors about to fall")
                    .font(Theme.body(15)).foregroundColor(Theme.ink)

                if model.catchesRemaining > 0 {
                    BrassButton(title: "CATCH IT",
                                subtitle: "\(model.catchesRemaining) of \(model.catchCap) left") {
                        model.takeCatch()
                    }
                } else {
                    // Out of saves, not unlocked. Peak loss-aversion: unlock + save this run.
                    BrassButton(title: "UNLOCK 3 SAVES",
                                subtitle: "\(model.unlockPriceText) · catch this tower") {
                        model.buyUnlock(reviveNow: true)
                    }
                }
                Button("let it fall") { Haptics.warning(); model.declineCatch() }
                    .font(Theme.body(14)).foregroundColor(Theme.brassDk)
                Spacer().frame(height: 40)
            }
        }
        .transition(.opacity)
    }
}

struct GameOverView: View {
    @EnvironmentObject var model: GameViewModel
    var body: some View {
        ZStack {
            Theme.ink.opacity(0.32).ignoresSafeArea()
            VStack(spacing: 16) {
                Text("TOPPLED")
                    .font(Theme.display(40)).foregroundColor(Theme.rust)
                Text("banked: 0 — you pushed too far")
                    .font(Theme.body(15)).foregroundColor(Theme.steam)
                Text("best — \(model.best)")
                    .font(Theme.body(14)).foregroundColor(Theme.brassHi)
                BrassButton(title: "BUILD AGAIN") { model.startRun() }
                if !model.isUnlocked {
                    // Soft second-chance placement (the run is already lost; unlocks future runs).
                    Button("unlock 3 saves/run · \(model.unlockPriceText)") {
                        model.buyUnlock(reviveNow: false)
                    }
                    .font(Theme.body(13)).foregroundColor(Theme.copper)
                }
                Button("menu") { model.backToMenu() }
                    .font(Theme.body(14)).foregroundColor(Theme.brassHi)
            }
        }
    }
}

/// The triumphant moment — height locked in, share the tower.
struct CashOutView: View {
    @EnvironmentObject var model: GameViewModel
    @State private var sharing = false
    var body: some View {
        ZStack {
            Theme.ink.opacity(0.28).ignoresSafeArea()
            VStack(spacing: 14) {
                Text("BANKED")
                    .font(Theme.display(40)).foregroundColor(Theme.patina)
                Text("\(model.bankedHeight) floors")
                    .font(Theme.display(30)).foregroundColor(Theme.steam)
                if model.bankedHeight >= model.best {
                    Text("new best!").font(Theme.body(15)).foregroundColor(Theme.brassHi)
                }
                BrassButton(title: "SHARE TOWER") { sharing = true }
                BrassButton(title: "BUILD AGAIN") { model.startRun() }
                Button("menu") { model.backToMenu() }
                    .font(Theme.body(14)).foregroundColor(Theme.brassHi)
            }
        }
        .sheet(isPresented: $sharing) {
            ShareSheet(items: [ShareCard.render(height: model.bankedHeight,
                                                tower: model.shareImage)])
        }
    }
}
