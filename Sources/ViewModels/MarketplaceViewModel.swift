import Foundation
import SwiftUI

final class MarketplaceViewModel: ObservableObject {
    @Published var listings: [SnowboardListing]
    @Published var filterText: String = ""
    @Published var selectedTradeOption: SnowboardListing.TradeOption? = nil
    @Published var selectedCondition: SnowboardListing.Condition? = nil
    init(listings: [SnowboardListing] = SampleData.listings) {
        self.listings = listings
    }

    var filteredListings: [SnowboardListing] {
        listings.filter { listing in
            let matchesKeyword: Bool
            if filterText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                matchesKeyword = true
            } else {
                matchesKeyword = listing.title.localizedCaseInsensitiveContains(filterText) ||
                    listing.description.localizedCaseInsensitiveContains(filterText) ||
                    listing.location.localizedCaseInsensitiveContains(filterText)
            }

            let matchesTrade = selectedTradeOption.map { $0 == listing.tradeOption } ?? true
            let matchesCondition = selectedCondition.map { $0 == listing.condition } ?? true
            return matchesKeyword && matchesTrade && matchesCondition
        }
    }

    func addListing(_ listing: SnowboardListing) {
        listings.insert(listing, at: 0)
    }

    func toggleFavorite(for listing: SnowboardListing) {
        guard let index = listings.firstIndex(where: { $0.id == listing.id }) else { return }
        listings[index].isFavorite.toggle()
    }

}
