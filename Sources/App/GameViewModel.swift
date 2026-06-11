import SwiftUI
import Combine
import UIKit

/// Lifecycle phases. Completion (a banked run) is reachable only via .cashedOut;
/// a topple with no saves left lands in .gameOver with zero banked — that's the
/// press-your-luck contract ("die = 0").
enum GamePhase: Equatable {
    case menu
    case playing
    case toppling      // tower passed the stability threshold; the save offer is live
    case gameOver      // toppled, nothing banked
    case cashedOut     // player chose to stop; height banked, brag earned
}

/// Fully free, no IAP, no ads. Every run gives `Tuning.catchesPerRun` (3) saves
/// ("catches"). Taking a save costs nothing; running out and toppling banks zero.
@MainActor
final class GameViewModel: ObservableObject {
    // Run state (scene writes, UI reads)
    @Published var phase: GamePhase = .menu
    @Published var height: Int = 0
    @Published var bankedHeight: Int = 0
    @Published var best: Int = 0
    @Published var leanFraction: Double = 0      // 0 = plumb, 1 = toppling (drives the gauge)
    @Published var catchesRemaining: Int = Tuning.catchesPerRun
    @Published var lastWasPerfect: Bool = false

    // Player
    @Published var soundOn: Bool = true
    @Published var shareImage: UIImage? = nil

    let catchCap: Int = Tuning.catchesPerRun

    // Systems
    private let scores = ScoreStore()

    /// Set by RootView once the SpriteKit scene exists, so UI buttons can drive gameplay.
    weak var scene: GameScene?

    init() { self.best = scores.best }

    func boot() async {}

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

    /// Use a save to catch the toppling tower.
    func takeCatch() {
        guard phase == .toppling, catchesRemaining > 0 else { return }
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

    // MARK: - Callbacks from the scene

    func sceneDidSettle(height: Int, perfect: Bool) {
        self.height = height
        self.lastWasPerfect = perfect
    }

    func sceneDidUpdateLean(_ f: Double) { leanFraction = f }

    func sceneDidBeginToppling() {
        guard phase == .playing else { return }
        if catchesRemaining > 0 {
            phase = .toppling            // offer the save
        } else {
            declineCatch()               // out of saves -> game over
        }
    }
}
