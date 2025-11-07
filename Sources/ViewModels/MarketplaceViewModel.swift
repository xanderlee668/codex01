import Combine
import Foundation

final class MarketplaceViewModel: ObservableObject {
    enum ChatStatus: Equatable {
        case available
        case awaitingCurrentUserFollowBack
        case awaitingMutualFollow

        var canOpenThread: Bool {
            switch self {
            case .available:
                return true
            case .awaitingCurrentUserFollowBack, .awaitingMutualFollow:
                return false
            }
        }
    }

    @Published var listings: [SnowboardListing]
    @Published var filterText: String = ""
    @Published var selectedTradeOption: SnowboardListing.TradeOption? = nil
    @Published var selectedCondition: SnowboardListing.Condition? = nil
    @Published private(set) var currentUser: SnowboardListing.Seller
    @Published private(set) var followingSellerIDs: Set<UUID>
    @Published private(set) var followersOfCurrentUser: Set<UUID>
    @Published var threads: [MessageThread]

    init(
        listings: [SnowboardListing] = SampleData.seedListings,
        account: UserAccount = SampleData.defaultAccount,
        threads: [MessageThread]? = nil
    ) {
        self.listings = listings
        self.currentUser = account.seller
        self.followingSellerIDs = account.followingSellerIDs
        self.followersOfCurrentUser = account.followersOfCurrentUser
        if let threads {
            self.threads = threads
        } else {
            self.threads = SampleData.seedThreads(for: listings, account: account)
        }
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

    func isFollowing(_ seller: SnowboardListing.Seller) -> Bool {
        followingSellerIDs.contains(seller.id)
    }

    func sellerFollowsCurrentUser(_ seller: SnowboardListing.Seller) -> Bool {
        followersOfCurrentUser.contains(seller.id)
    }

    func canChat(with seller: SnowboardListing.Seller) -> Bool {
        isFollowing(seller) && sellerFollowsCurrentUser(seller)
    }

    func chatStatus(with seller: SnowboardListing.Seller) -> ChatStatus {
        if canChat(with: seller) {
            return .available
        } else if sellerFollowsCurrentUser(seller) {
            return .awaitingCurrentUserFollowBack
        } else {
            return .awaitingMutualFollow
        }
    }

    func toggleFollow(for seller: SnowboardListing.Seller) {
        if isFollowing(seller) {
            followingSellerIDs.remove(seller.id)
        } else {
            followingSellerIDs.insert(seller.id)
        }
    }

    func thread(for listing: SnowboardListing) -> MessageThread? {
        guard canChat(with: listing.seller) else { return nil }

        if let index = threads.firstIndex(where: { $0.listing.id == listing.id }) {
            if threads[index].listing != listing {
                threads[index].listing = listing
            }
            return threads[index]
        }

        let seedMessages = SampleData.messageHistory(for: listing.seller.id)
        let threadID = SampleData.threadIdentifier(for: listing.seller.id) ?? UUID()
        let newThread = MessageThread(id: threadID, listing: listing, messages: seedMessages)
        threads.append(newThread)
        return newThread
    }

    @discardableResult
    func sendMessage(_ text: String, in thread: MessageThread) -> Message? {
        guard let index = threads.firstIndex(where: { $0.id == thread.id }) else { return nil }
        let message = Message(id: UUID(), sender: .buyer, text: text, timestamp: Date())
        threads[index].messages.append(message)
        return message
    }

    func configure(with account: UserAccount) {
        currentUser = account.seller
        followingSellerIDs = account.followingSellerIDs
        followersOfCurrentUser = account.followersOfCurrentUser
        threads = SampleData.seedThreads(for: listings, account: account)
    }
}
