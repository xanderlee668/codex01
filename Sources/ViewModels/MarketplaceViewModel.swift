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

    private let apiClient: APIClient

    init(account: UserAccount, apiClient: APIClient, autoRefresh: Bool = true) {
        self.currentUser = account.seller
        self.followingSellerIDs = account.followingSellerIDs
        self.followersOfCurrentUser = account.followersOfCurrentUser
        self.listings = []
        self.threads = []
        self.groupTrips = []
        self.tripThreads = []
        self.apiClient = apiClient

        if autoRefresh {
            Task { await refreshListings() }
        }
    }

    func configure(with account: UserAccount) {
        currentUser = account.seller
        followingSellerIDs = account.followingSellerIDs
        followersOfCurrentUser = account.followersOfCurrentUser
        Task { await refreshListings() }
    }

    func refreshListings() async {
        isLoading = true
        lastError = nil
        do {
            let remoteListings = try await apiClient.fetchListings()
            listings = remoteListings
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
            lastError = nil
            return true
        } catch {
            lastError = error.localizedDescription
            return false
        }
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
}

extension MarketplaceViewModel {
    static func preview() -> MarketplaceViewModel {
        // 创建一个假的卖家
        let fakeSeller = SnowboardListing.Seller(
            id: UUID(),
            nickname: "Preview Rider",
            rating: 4.8,
            dealsCount: 23
        )

        // 创建一个假的用户账户
        let fakeAccount = UserAccount(
            id: UUID(),
            username: "previewUser",
            password: "password123",
            seller: fakeSeller,
            followingSellerIDs: [],
            followersOfCurrentUser: [],
            email: "preview@example.com",
            location: "Zermatt",
            bio: "Snowboarder for life!"
        )

        // 假 API 客户端
        let apiClient = APIClient()

        // 初始化 ViewModel
        let model = MarketplaceViewModel(
            account: fakeAccount,
            apiClient: apiClient,
            autoRefresh: false
        )

        // 添加一些假数据（可选）
        model.listings = []
        model.groupTrips = []
        model.tripThreads = []

        return model
    }
}





