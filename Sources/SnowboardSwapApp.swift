import SwiftUI

@main
struct SnowboardSwapApp: App {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            AuthView()
                .environmentObject(authViewModel)
                .environmentObject(authViewModel.marketplace)
        }
    }
}
