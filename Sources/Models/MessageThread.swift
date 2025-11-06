import Foundation

struct Message: Identifiable, Hashable {
    enum Sender {
        case buyer
        case seller

        var name: String {
            switch self {
            case .buyer:
                return "我"
            case .seller:
                return "卖家"
            }
        }
    }

    let id: UUID
    var sender: Sender
    var text: String
    var timestamp: Date
}

struct MessageThread: Identifiable, Hashable {
    let id: UUID
    var seller: SnowboardListing.Seller
    var listing: SnowboardListing?
    var messages: [Message]

    var title: String {
        listing?.title ?? seller.nickname
    }
}

extension Message {
    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension MessageThread {
    static func == (lhs: MessageThread, rhs: MessageThread) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
