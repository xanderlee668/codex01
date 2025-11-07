import SwiftUI

@main
struct SnowboardSwapApp: App {
    @StateObject private var auth = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            AuthView()
                .environmentObject(auth)
        }
    }
}
