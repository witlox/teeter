import SwiftUI
import GameKit

/// SwiftUI wrapper around GKGameCenterViewController so it can be presented
/// via .sheet. The system controller handles its own dismiss button; we listen
/// via the delegate and flip the binding so SwiftUI's sheet animation stays in
/// sync.
struct LeaderboardSheet: UIViewControllerRepresentable {
    @Binding var isPresented: Bool

    func makeUIViewController(context: Context) -> GKGameCenterViewController {
        let vc = GKGameCenterViewController(
            leaderboardID: GameCenter.leaderboardID,
            playerScope: .global,
            timeScope: .allTime
        )
        vc.gameCenterDelegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ vc: GKGameCenterViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(isPresented: $isPresented) }

    final class Coordinator: NSObject, GKGameCenterControllerDelegate {
        @Binding var isPresented: Bool
        init(isPresented: Binding<Bool>) { self._isPresented = isPresented }
        func gameCenterViewControllerDidFinish(_ vc: GKGameCenterViewController) {
            isPresented = false
        }
    }
}
