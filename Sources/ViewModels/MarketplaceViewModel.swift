import Combine
import Foundation

@MainActor
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

    enum TripJoinState: Equatable {
        case organizer
        case approved
        case pending
        case notRequested
    }

    @Published var listings: [SnowboardListing]
    @Published var filterText: String = ""
    @Published var selectedTradeOption: SnowboardListing.TradeOption? = nil
    @Published var selectedCondition: SnowboardListing.Condition? = nil
    @Published private(set) var currentUser: SnowboardListing.Seller
    @Published private(set) var followingSellerIDs: Set<UUID>
    @Published private(set) var followersOfCurrentUser: Set<UUID>
    @Published var threads: [MessageThread]
    @Published var groupTrips: [GroupTrip]
    @Published var tripThreads: [GroupTripThread]
    @Published var isLoading: Bool = false
    @Published var lastError: String? = nil
    @Published private(set) var isUpdatingFollow: Bool = false
    @Published private(set) var favoriteUpdatesInFlight: Set<UUID> = []

    private let apiClient: APIClient
    private var accountSnapshot: UserAccount

    var onAccountChange: ((UserAccount) -> Void)?

    init(account: UserAccount, apiClient: APIClient, autoRefresh: Bool = true) {
        self.currentUser = account.seller
        self.followingSellerIDs = account.followingSellerIDs
        self.followersOfCurrentUser = account.followersOfCurrentUser
        self.listings = []
        self.threads = []
        self.groupTrips = []
        self.tripThreads = []
        self.apiClient = apiClient
        self.accountSnapshot = account

        synchronizeSocialFeatures(resetThreads: true)

        if autoRefresh {
            Task { await refreshListings() }
        }
    }

    func configure(with account: UserAccount) {
        currentUser = account.seller
        followingSellerIDs = account.followingSellerIDs
        followersOfCurrentUser = account.followersOfCurrentUser
        accountSnapshot = account
        synchronizeSocialFeatures(resetThreads: true)
        onAccountChange?(accountSnapshot)
        Task { await refreshListings() }
    }

    func refreshListings() async {
        // 调用后端 GET /api/listings，刷新前端展示的滑雪板列表。
        isLoading = true
        lastError = nil
        do {
            let existingPhotos = Dictionary(uniqueKeysWithValues: listings.map { ($0.id, $0.photos) })
            let remoteListings = try await apiClient.fetchListings()
            listings = remoteListings.map { listing in
                var listing = listing
                if let photos = existingPhotos[listing.id], !photos.isEmpty {
                    listing.photos = photos
                }
                return listing
            }
            synchronizeThreadsWithListings()

            if let graph = try? await apiClient.fetchSocialGraph() {
                apply(graph: graph)
                synchronizeThreadsWithListings()
            }
        } catch {
            lastError = error.localizedDescription
        }
        isLoading = false
    }

    var filteredListings: [SnowboardListing] {
        let locale = Locale.current
        let normalizedTokens = filterText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(whereSeparator: { $0.isWhitespace })
            .map { String($0).folding(options: [.caseInsensitive, .diacriticInsensitive], locale: locale) }

        return listings.filter { listing in
            let matchesKeyword: Bool
            if normalizedTokens.isEmpty {
                matchesKeyword = true
            } else {
                let searchableFields = [
                    listing.title,
                    listing.description,
                    listing.location,
                    listing.seller.nickname
                ].map { $0.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: locale) }

                matchesKeyword = normalizedTokens.allSatisfy { token in
                    searchableFields.contains { $0.contains(token) }
                }
            }

            let matchesTrade = selectedTradeOption.map { $0 == listing.tradeOption } ?? true
            let matchesCondition = selectedCondition.map { $0 == listing.condition } ?? true
            return matchesKeyword && matchesTrade && matchesCondition
        }
    }

    var sortedTrips: [GroupTrip] {
        groupTrips.sorted(by: { $0.startDate < $1.startDate })
    }

    @discardableResult
    func createListing(
        title: String,
        description: String,
        price: Double,
        location: String,
        tradeOption: SnowboardListing.TradeOption,
        condition: SnowboardListing.Condition
    ) async -> Bool {
        // 对应后端 POST /api/listings。
        // 后端需根据登录用户 ID 自动设置卖家信息，并返回完整的 Listing。
        do {
            let draft = CreateListingRequest(
                title: title,
                description: description,
                condition: condition,
                price: price,
                location: location,
                tradeOption: tradeOption
            )
            let created = try await apiClient.createListing(draft: draft)
            listings.insert(created, at: 0)
            synchronizeThreadsWithListings()
            lastError = nil
            return true
        } catch {
            lastError = error.localizedDescription
            return false
        }
    }

    func toggleFavorite(for listing: SnowboardListing) async {
        guard let index = listings.firstIndex(where: { $0.id == listing.id }) else { return }
        guard !favoriteUpdatesInFlight.contains(listing.id) else { return }

        favoriteUpdatesInFlight.insert(listing.id)
        defer { favoriteUpdatesInFlight.remove(listing.id) }

        do {
            let updated: SnowboardListing
            if listing.isFavorite {
                updated = try await apiClient.unfavoriteListing(listing.id)
            } else {
                updated = try await apiClient.favoriteListing(listing.id)
            }
            var merged = updated
            merged.photos = listings[index].photos
            listings[index] = merged
            synchronizeThreadsWithListings()
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }
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

    @discardableResult
    func toggleFollow(for seller: SnowboardListing.Seller) async -> Bool {
        guard seller.id != currentUser.id else { return false }

        isUpdatingFollow = true
        defer { isUpdatingFollow = false }

        do {
            let graph: APIClient.SocialGraph
            if isFollowing(seller) {
                graph = try await apiClient.unfollowSeller(seller.id)
            } else {
                graph = try await apiClient.followSeller(seller.id)
            }
            apply(graph: graph)
            synchronizeThreadsWithListings()
            lastError = nil
            return true
        } catch {
            lastError = error.localizedDescription
            return false
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

        let newThread = MessageThread(id: UUID(), listing: listing, messages: [])
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

    func tripJoinState(for trip: GroupTrip) -> TripJoinState {
        if trip.organizer.id == currentUser.id {
            return .organizer
        }
        if trip.approvedParticipantIDs.contains(currentUser.id) {
            return .approved
        }
        if trip.hasPendingRequest(from: currentUser) {
            return .pending
        }
        return .notRequested
    }

    @discardableResult
    func requestToJoin(trip: GroupTrip) -> GroupTrip.JoinRequest? {
        guard tripJoinState(for: trip) == .notRequested else { return nil }
        guard let index = groupTrips.firstIndex(where: { $0.id == trip.id }) else { return nil }
        let request = GroupTrip.JoinRequest(id: UUID(), applicant: currentUser, requestedAt: Date())
        groupTrips[index].pendingRequests.append(request)
        return request
    }

    func approve(_ request: GroupTrip.JoinRequest, in trip: GroupTrip) {
        guard trip.organizer.id == currentUser.id else { return }
        guard let index = groupTrips.firstIndex(where: { $0.id == trip.id }) else { return }
        guard let requestIndex = groupTrips[index].pendingRequests.firstIndex(where: { $0.id == request.id }) else { return }
        groupTrips[index].pendingRequests.remove(at: requestIndex)
        groupTrips[index].approvedParticipantIDs.insert(request.applicant.id)
    }

    func revoke(_ request: GroupTrip.JoinRequest, in trip: GroupTrip) {
        guard let index = groupTrips.firstIndex(where: { $0.id == trip.id }) else { return }
        groupTrips[index].pendingRequests.removeAll { $0.id == request.id }
    }

    func canAccessTripChat(for trip: GroupTrip) -> Bool {
        trip.includesParticipant(currentUser)
    }

    func tripThread(for trip: GroupTrip) -> GroupTripThread? {
        guard canAccessTripChat(for: trip) else { return nil }

        if let index = tripThreads.firstIndex(where: { $0.tripID == trip.id }) {
            return tripThreads[index]
        }

        let thread = GroupTripThread(id: UUID(), tripID: trip.id, messages: [])
        tripThreads.append(thread)
        return thread
    }

    @discardableResult
    func sendTripMessage(_ text: String, in thread: GroupTripThread, sender: SnowboardListing.Seller? = nil) -> GroupTripMessage? {
        guard let index = tripThreads.firstIndex(where: { $0.id == thread.id }) else { return nil }
        let author = sender ?? currentUser
        let role: GroupTripMessage.Role
        if let trip = groupTrips.first(where: { $0.id == thread.tripID }), trip.organizer.id == author.id {
            role = .organizer
        } else {
            role = .participant
        }
        let message = GroupTripMessage(
            id: UUID(),
            senderID: author.id,
            senderName: author.nickname,
            role: role,
            text: text,
            timestamp: Date()
        )
        tripThreads[index].messages.append(message)
        return message
    }

    func createTrip(
        title: String,
        resort: String,
        startDate: Date,
        departureLocation: String,
        participantRange: ClosedRange<Int>,
        estimatedCostPerPerson: Double,
        description: String
    ) -> GroupTrip {
        let trip = GroupTrip(
            id: UUID(),
            title: title,
            resort: resort,
            departureLocation: departureLocation,
            startDate: startDate,
            participantRange: participantRange,
            estimatedCostPerPerson: estimatedCostPerPerson,
            description: description,
            organizer: currentUser,
            approvedParticipantIDs: [] as Set<UUID>,
            pendingRequests: []
        )
        groupTrips.insert(trip, at: 0)
        return trip
    }

    func trip(withID id: UUID) -> GroupTrip? {
        groupTrips.first(where: { $0.id == id })
    }

    // MARK: - Sample data helpers

    private func synchronizeSocialFeatures(resetThreads: Bool) {
        groupTrips = SampleData.seedTrips(for: accountSnapshot)
        tripThreads = SampleData.seedTripThreads(for: groupTrips, account: accountSnapshot)
        synchronizeThreadsWithListings(reset: resetThreads)
    }

    private func apply(graph: APIClient.SocialGraph) {
        followingSellerIDs = graph.followingSellerIDs
        followersOfCurrentUser = graph.followersOfCurrentUser
        accountSnapshot.followingSellerIDs = graph.followingSellerIDs
        accountSnapshot.followersOfCurrentUser = graph.followersOfCurrentUser
        onAccountChange?(accountSnapshot)
    }

    private func synchronizeThreadsWithListings(reset: Bool = false) {
        if reset || threads.isEmpty {
            let baseListings = listings.isEmpty ? SampleData.seedListings : listings
            threads = SampleData.seedThreads(for: baseListings, account: accountSnapshot)
            return
        }

        let lookup = Dictionary(uniqueKeysWithValues: listings.map { ($0.id, $0) })
        for index in threads.indices {
            guard let refreshed = lookup[threads[index].listing.id] else { continue }
            threads[index].listing = refreshed
        }
    }
}

#if DEBUG
extension MarketplaceViewModel {
    static func preview(account: UserAccount = SampleData.defaultAccount) -> MarketplaceViewModel {
        let model = MarketplaceViewModel(account: account, apiClient: APIClient(), autoRefresh: false)
        model.listings = SampleData.seedListings
        model.groupTrips = SampleData.seedTrips(for: account)
        model.tripThreads = SampleData.seedTripThreads(for: model.groupTrips, account: account)
        return model
    }
}
#endif
