import SwiftUI

@main
struct SnowboardSwapApp: App {
    @StateObject private var marketplace = MarketplaceViewModel()

    var body: some Scene {
        WindowGroup {
            ListingListView()
                .environmentObject(marketplace)
        }
    }
}
