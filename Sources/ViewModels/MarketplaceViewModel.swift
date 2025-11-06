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
            let keyword = filterText.trimmingCharacters(in: .whitespacesAndNewlines)
            let matchesKeyword: Bool
            if keyword.isEmpty {
                matchesKeyword = true
            } else {
                matchesKeyword = listing.title.localizedCaseInsensitiveContains(keyword) ||
                    listing.description.localizedCaseInsensitiveContains(keyword) ||
                    listing.location.localizedCaseInsensitiveContains(keyword) ||
                    listing.seller.nickname.localizedCaseInsensitiveContains(keyword)
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

    func thread(with seller: SnowboardListing.Seller) -> MessageThread {
        if let index = threads.firstIndex(where: { $0.seller.id == seller.id }) {
            if threads[index].seller != seller {
                threads[index].seller = seller
            }
            threads[index].listing = nil
            return threads[index]
        }
        let newThread = MessageThread(id: UUID(), seller: seller, listing: nil, messages: SampleData.demoMessages)
        threads.append(newThread)
        return newThread
    }

    func thread(for listing: SnowboardListing) -> MessageThread {
        let existing = thread(with: listing.seller)
        if let index = threads.firstIndex(where: { $0.id == existing.id }) {
            threads[index].listing = listing
            return threads[index]
        }
        return existing
    }

    func sendMessage(_ text: String, in thread: MessageThread) {
        guard let index = threads.firstIndex(where: { $0.id == thread.id }) else { return }
        let message = Message(id: UUID(), sender: .buyer, text: text, timestamp: Date())
        threads[index].messages.append(message)
    }
}
