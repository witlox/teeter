import SwiftUI
import Combine
import UIKit

/// Lifecycle phases. Completion (a banked run) is reachable only via .cashedOut;
/// a topple with no saves left lands in .gameOver with zero banked — that's the
/// press-your-luck contract ("die = 0").
enum GamePhase: Equatable {
    case menu
    case playing
    case toppling      // tower passed the stability threshold; the save/upsell offer is live
    case gameOver      // toppled, nothing banked
    case cashedOut     // player chose to stop; height banked, brag earned
}

/// MONETISATION: IAP-only, no ads.
/// - Every run gives 1 free save ("catch") by default.
/// - A single non-consumable IAP ("Unlock 3 Revives", Family Sharing on) raises the
///   per-run cap from 1 to 3, forever. It is a strict upgrade, never a penalty.
/// - The unlock is offered at the highest-intent moment: the instant you topple with
///   no free save left ("I was that close"). Buying there both unlocks AND saves the
///   current run.
@MainActor
final class GameViewModel: ObservableObject {
    // Run state (scene writes, UI reads)
    @Published var phase: GamePhase = .menu
    @Published var height: Int = 0
    @Published var bankedHeight: Int = 0
    @Published var best: Int = 0
    @Published var leanFraction: Double = 0      // 0 = plumb, 1 = toppling (drives the gauge)
    @Published var catchesRemaining: Int = Tuning.defaultCatchesPerRun
    @Published var lastWasPerfect: Bool = false

    // Player / commerce
    @Published var isUnlocked: Bool = false      // owns "Unlock 3 Revives"
    @Published var soundOn: Bool = true
    @Published var unlockPriceText: String = "$2.99"
    @Published var shareImage: UIImage? = nil

    /// Saves available per run for this player: 3 once unlocked, otherwise 1.
    var catchCap: Int { isUnlocked ? Tuning.maxCatchesPerRun : Tuning.defaultCatchesPerRun }

    // Systems
    let store = StoreManager()
    private let scores = ScoreStore()

    /// Set by RootView once the SpriteKit scene exists, so UI buttons can drive gameplay.
    weak var scene: GameScene?

    init() { self.best = scores.best }

    func boot() async {
        await store.load()
        isUnlocked = store.isUnlocked
        unlockPriceText = store.unlockPriceText ?? "$2.99"
        store.onEntitlementChange = { [weak self] unlocked in
            Task { @MainActor in self?.isUnlocked = unlocked }
        }
    }

    // MARK: - Intents from UI

    func startRun() {
        height = 0
        bankedHeight = 0
        leanFraction = 0
        catchesRemaining = catchCap
        phase = .playing
        scene?.startRun()
    }

    /// "Bank by not placing." Voluntarily stop; height is locked in and becomes the brag.
    func cashOut() {
        guard phase == .playing else { return }
        bankedHeight = height
        if height > best { best = height; scores.best = height }
        shareImage = scene?.snapshotTower()
        phase = .cashedOut
        scene?.freeze()
    }

    /// Use a free/owned save to catch the toppling tower. No ads, no cost.
    func takeCatch() {
        guard phase == .toppling, catchesRemaining > 0 else { return }
        applyCatch()
    }

    private func applyCatch() {
        catchesRemaining -= 1
        phase = .playing
        scene?.restoreLastStable()
    }

    /// Topple with no save taken => lose everything.
    func declineCatch() {
        bankedHeight = 0
        phase = .gameOver
        scene?.completeTopple()
    }

    func backToMenu() {
        phase = .menu
        height = 0
        leanFraction = 0
        scene?.reset()
    }

    /// Buy the "Unlock 3 Revives" non-consumable.
    /// - Parameter reviveNow: when bought at the topple moment, also grant the freshly
    ///   unlocked saves for the current run and immediately catch the tower.
    func buyUnlock(reviveNow: Bool) {
        Task {
            let ok = await store.purchaseUnlock()
            guard ok else { return }
            let usedThisRun = Tuning.defaultCatchesPerRun - catchesRemaining  // was capped at 1
            isUnlocked = true
            if reviveNow, phase == .toppling {
                catchesRemaining = max(0, Tuning.maxCatchesPerRun - usedThisRun)
                if catchesRemaining > 0 { applyCatch() } else { declineCatch() }
            }
        }
    }

    func restorePurchases() { Task { await store.restore() } }

    // MARK: - Callbacks from the scene

    func sceneDidSettle(height: Int, perfect: Bool) {
        self.height = height
        self.lastWasPerfect = perfect
    }

    func sceneDidUpdateLean(_ f: Double) { leanFraction = f }

    func sceneDidBeginToppling() {
        guard phase == .playing else { return }
        if catchesRemaining > 0 {
            phase = .toppling            // free/owned save available
        } else if !isUnlocked {
            phase = .toppling            // out of free saves -> show the unlock offer
        } else {
            declineCatch()               // unlocked but all 3 used -> game over
        }
    }
}
