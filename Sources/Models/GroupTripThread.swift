import Foundation

struct GroupTripMessage: Identifiable, Equatable {
    enum Role {
        case organizer
        case participant
    }

    let id: UUID
    let senderID: UUID
    let senderName: String
    let role: Role
    let text: String
    let timestamp: Date
}

struct GroupTripThread: Identifiable, Equatable {
    let id: UUID
    let tripID: UUID
    var messages: [GroupTripMessage]
}
