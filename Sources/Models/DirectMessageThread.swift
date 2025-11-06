import Foundation

struct DirectMessage: Identifiable, Hashable {
    let id: UUID
    let senderID: UUID
    var text: String
    var timestamp: Date
}

struct DirectMessageThread: Identifiable, Hashable {
    let id: UUID
    var participantIDs: Set<UUID>
    var messages: [DirectMessage]

    init(id: UUID, participantIDs: Set<UUID>, messages: [DirectMessage] = []) {
        self.id = id
        self.participantIDs = participantIDs
        self.messages = messages.sorted { $0.timestamp < $1.timestamp }
    }

    init(id: UUID, participantIDs: [UUID], messages: [DirectMessage] = []) {
        self.init(id: id, participantIDs: Set(participantIDs), messages: messages)
    }
}
