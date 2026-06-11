import GameKit
import UIKit

/// Thin wrapper around GameKit. Apple's own framework — not a third-party SDK,
/// so it doesn't violate the "no SDKs" invariant. Auth runs at app launch; if
/// the player declines or isn't signed in to Game Center, the rest of the game
/// works exactly the same. Leaderboards are an optional layer, never a gate.
@MainActor
final class GameCenter {
    /// Leaderboard identifier registered in App Store Connect →
    /// Features → Leaderboards. Reverse-DNS, kept in sync with the bundle id.
    static let leaderboardID = "io.witlox.teeter.tower_height"

    /// Kicked off from GameViewModel.boot(). The system shows its own sign-in
    /// sheet on first launch if needed; we route it through the foreground
    /// window scene. Any error is silent — the game just runs without a
    /// leaderboard layer.
    func authenticate() {
        GKLocalPlayer.local.authenticateHandler = { vc, _ in
            if let vc = vc { Self.present(vc) }
        }
    }

    var isAuthenticated: Bool { GKLocalPlayer.local.isAuthenticated }

    /// Submit a banked tower height. Apple keeps the maximum per-player score
    /// automatically, so pushing every cash-out is both safe and simpler than
    /// duplicating beat-your-best logic at this layer. Calls on an unauth'd
    /// player are a silent no-op.
    func submit(score: Int) {
        guard isAuthenticated else { return }
        GKLeaderboard.submitScore(score, context: 0, player: GKLocalPlayer.local,
                                  leaderboardIDs: [Self.leaderboardID]) { _ in }
    }

    private static func present(_ vc: UIViewController) {
        guard let scene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }),
              let root = scene.keyWindow?.rootViewController else { return }
        root.present(vc, animated: true)
    }
}
