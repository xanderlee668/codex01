import SwiftUI

@main
struct SnowboardSwapApp: App {
    @StateObject private var marketplace = MarketplaceViewModel()
    @StateObject private var auth = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            if auth.currentUser != nil {
                ListingListView()
                    .environmentObject(marketplace)
                    .environmentObject(auth)
            } else {
                AuthView()
                    .environmentObject(auth)
            }
        }
    }
}
