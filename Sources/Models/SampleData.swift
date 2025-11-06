import Foundation

enum SampleData {
    static let users: [User] = [
        .init(id: UUID(), displayName: "板痴阿豪", email: "hao@snowboardswap.cn", password: "password123", dealsCount: 86, rating: 4.9),
        .init(id: UUID(), displayName: "北区小雪", email: "snow@bj.cn", password: "password123", dealsCount: 42, rating: 4.7),
        .init(id: UUID(), displayName: "老炮儿滑雪", email: "laopao@ski.cn", password: "password123", dealsCount: 120, rating: 5.0),
        .init(id: UUID(), displayName: "测试用户", email: "test", password: "12345678", dealsCount: 0, rating: 5.0)
    ]

    static let sellers: [SnowboardListing.Seller] = users.map { user in
        SnowboardListing.Seller(
            id: user.id,
            nickname: user.displayName,
            rating: user.rating,
            dealsCount: user.dealsCount
        )
    }

    static let listings: [SnowboardListing] = [
        .init(
            id: UUID(),
            title: "Burton Custom 154",
            description: "经典全山板，软硬适中，适合北区巡航与小跳台。附赠两套固定器配件。",
            condition: .likeNew,
            price: 2800,
            location: "北京·怀北",
            tradeOption: .faceToFace,
            isFavorite: false,
            imageName: "board_blue",
            seller: sellers[0]
        ),
        .init(
            id: UUID(),
            title: "Jones Mountain Twin 157",
            description: "22-23雪季购入，只下雪7次，边刃保养良好，附带Dakine滑雪包。",
            condition: .good,
            price: 3200,
            location: "张家口·崇礼",
            tradeOption: .hybrid,
            isFavorite: true,
            imageName: "board_red",
            seller: sellers[1]
        ),
        .init(
            id: UUID(),
            title: "Yes Basic 152",
            description: "柔软易操控，适合女孩子或刚进阶的朋友，板头有轻微蹭痕，不影响使用。",
            condition: .good,
            price: 2100,
            location: "吉林·万科",
            tradeOption: .courier,
            isFavorite: false,
            imageName: "board_green",
            seller: sellers[2]
        )
    ]

    static let demoMessages: [Message] = [
        .init(id: UUID(), sender: .buyer, text: "你好，请问板子还在吗？", timestamp: Date()),
        .init(id: UUID(), sender: .seller, text: "在的，本周末可以在怀北面交。", timestamp: Date().addingTimeInterval(3600)),
        .init(id: UUID(), sender: .buyer, text: "可以小刀到2600吗？", timestamp: Date().addingTimeInterval(7200))
    ]

    static let alternateMessages: [Message] = [
        .init(id: UUID(), sender: .seller, text: "嗨，我这周末也会在崇礼，方便看板吗？", timestamp: Date().addingTimeInterval(-86000)),
        .init(id: UUID(), sender: .buyer, text: "没问题，周日午后可以吗？", timestamp: Date().addingTimeInterval(-83000)),
        .init(id: UUID(), sender: .seller, text: "可以，到时给你定位。", timestamp: Date().addingTimeInterval(-82000))
    ]

    static let initialThreads: [MessageThread] = [
        .init(id: UUID(), seller: sellers[0], listing: listings[0], messages: demoMessages),
        .init(id: UUID(), seller: sellers[1], listing: listings[1], messages: alternateMessages)
    ]

    static let defaultFollowingMap: [UUID: Set<UUID>] = {
        guard let currentUser = users.last else { return [:] }
        let followedSellers = Set(sellers.prefix(2).map(\.id))
        return [currentUser.id: followedSellers]
    }()
}
