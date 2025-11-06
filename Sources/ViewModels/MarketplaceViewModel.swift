import Foundation
import SwiftUI

final class MarketplaceViewModel: ObservableObject {
    @Published var listings: [SnowboardListing]
    @Published var filterText: String = ""
    @Published var selectedTradeOption: SnowboardListing.TradeOption? = nil
    @Published var selectedCondition: SnowboardListing.Condition? = nil
    @Published var threads: [MessageThread]

    init(listings: [SnowboardListing] = SampleData.listings,
         threads: [MessageThread] = []) {
        self.listings = listings
        self.threads = threads
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

    func thread(for listing: SnowboardListing) -> MessageThread {
        if let index = threads.firstIndex(where: { $0.listing.id == listing.id }) {
            if threads[index].listing != listing {
                threads[index].listing = listing
            }
            return threads[index]
        }
        let newThread = MessageThread(id: UUID(), listing: listing, messages: SampleData.demoMessages)
        threads.append(newThread)
        return newThread
    }

    func sendMessage(_ text: String, in thread: MessageThread) {
        guard let index = threads.firstIndex(where: { $0.id == thread.id }) else { return }
        let message = Message(id: UUID(), sender: .buyer, text: text, timestamp: Date())
        threads[index].messages.append(message)
    }
}
