import Foundation

struct GroupTrip: Identifiable, Equatable {
    struct JoinRequest: Identifiable, Equatable {
        let id: UUID
        let applicant: SnowboardListing.Seller
        let requestedAt: Date
    }

    let id: UUID
    var title: String
    var resort: String
    var departureLocation: String
    var startDate: Date
    var participantRange: ClosedRange<Int>
    var estimatedCostPerPerson: Double
    var description: String
    var organizer: SnowboardListing.Seller
    var approvedParticipantIDs: Set<UUID>
    var pendingRequests: [JoinRequest]

    var minimumParticipants: Int { participantRange.lowerBound }
    var maximumParticipants: Int { participantRange.upperBound }

    var currentParticipantsCount: Int {
        // include organizer plus approved riders
        1 + approvedParticipantIDs.count
    }

    func includesParticipant(_ seller: SnowboardListing.Seller) -> Bool {
        seller.id == organizer.id || approvedParticipantIDs.contains(seller.id)
    }

    func hasPendingRequest(from seller: SnowboardListing.Seller) -> Bool {
        pendingRequests.contains(where: { $0.applicant.id == seller.id })
    }
}
