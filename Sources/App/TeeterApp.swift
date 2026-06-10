import SwiftUI

@main
struct TeeterApp: App {
    @StateObject private var model = GameViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(model)
                .statusBarHidden(true)
                .persistentSystemOverlays(.hidden)
                .task { await model.boot() }
        }
    }
}
