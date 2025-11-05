import SwiftUI

@main
struct SnowboardSwapApp: App {
    @StateObject private var marketplace = MarketplaceViewModel()
    @StateObject private var groupRideViewModel = GroupRideViewModel()
    @StateObject private var socialViewModel = SocialViewModel()

    var body: some Scene {
        WindowGroup {
            TabView {
                ListingListView()
                    .tabItem {
                        Label("集市", systemImage: "snowboard")
                    }

                GroupRideListView()
                    .tabItem {
                        Label("外滑组队", systemImage: "person.3.sequence")
                    }

                SocialConnectionsView()
                    .tabItem {
                        Label("关注", systemImage: "bubble.left.and.bubble.right")
                    }
            }
            .environmentObject(marketplace)
            .environmentObject(groupRideViewModel)
            .environmentObject(socialViewModel)
        }
    }
}
