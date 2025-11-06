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
    var listing: SnowboardListing
    var messages: [Message]
}
