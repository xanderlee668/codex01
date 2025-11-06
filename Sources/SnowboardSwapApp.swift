import SwiftUI

@main
struct SnowboardSwapApp: App {
    @StateObject private var marketplace = MarketplaceViewModel()
    @StateObject private var auth = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            if auth.currentUser != nil {
                MainTabView()
                    .environmentObject(marketplace)
                    .environmentObject(auth)
            } else {
                AuthView()
                    .environmentObject(auth)
            }
        }
    }
}

private struct MainTabView: View {
    @EnvironmentObject private var marketplace: MarketplaceViewModel
    @EnvironmentObject private var auth: AuthViewModel

    var body: some View {
        TabView {
            ListingListView()
                .tabItem {
                    Label("集市", systemImage: "cart")
                }

            MessagesListView()
                .tabItem {
                    Label("消息", systemImage: "bubble.left.and.bubble.right")
                }
        }
        .environmentObject(marketplace)
        .environmentObject(auth)
    }
}
