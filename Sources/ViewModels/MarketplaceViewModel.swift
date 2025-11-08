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

    init(
        listings: [SnowboardListing] = SampleData.seedListings,
        account: UserAccount = SampleData.defaultAccount,
        threads: [MessageThread]? = nil,
        groupTrips: [GroupTrip]? = nil,
        tripThreads: [GroupTripThread]? = nil
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

        if let groupTrips {
            self.groupTrips = groupTrips
        } else {
            self.groupTrips = SampleData.seedTrips(for: account)
        }

        if let tripThreads {
            self.tripThreads = tripThreads
        } else {
            self.tripThreads = SampleData.seedTripThreads(for: self.groupTrips, account: account)
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

    var sortedTrips: [GroupTrip] {
        groupTrips.sorted(by: { $0.startDate < $1.startDate })
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
        groupTrips[index].pendingRequests.removeAll(where: { $0.id == request.id })
        groupTrips[index].approvedParticipantIDs.insert(request.applicant.id)
    }

    func revoke(_ request: GroupTrip.JoinRequest, in trip: GroupTrip) {
        guard let index = groupTrips.firstIndex(where: { $0.id == trip.id }) else { return }
        groupTrips[index].pendingRequests.removeAll(where: { $0.id == request.id })
    }

    func canAccessTripChat(for trip: GroupTrip) -> Bool {
        trip.includesParticipant(currentUser)
    }

    func tripThread(for trip: GroupTrip) -> GroupTripThread? {
        guard canAccessTripChat(for: trip) else { return nil }

        if let index = tripThreads.firstIndex(where: { $0.tripID == trip.id }) {
            return tripThreads[index]
        }

        let messages = SampleData.tripMessages(for: trip.id)
        let threadID = SampleData.tripThreadIdentifier(for: trip.id) ?? UUID()
        let thread = GroupTripThread(id: threadID, tripID: trip.id, messages: messages)
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

    func configure(with account: UserAccount) {
        currentUser = account.seller
        followingSellerIDs = account.followingSellerIDs
        followersOfCurrentUser = account.followersOfCurrentUser
        threads = SampleData.seedThreads(for: listings, account: account)
        groupTrips = SampleData.seedTrips(for: account)
        tripThreads = SampleData.seedTripThreads(for: groupTrips, account: account)
    }
}
