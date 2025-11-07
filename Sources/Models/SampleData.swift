import Foundation

enum SampleData {
    private static let user1ID = UUID()
    private static let user2ID = UUID()
    private static let user3ID = UUID()

    static let users: [User] = [
        .init(
            id: user1ID,
            displayName: "板痴阿豪",
            email: "hao@snowboardswap.cn",
            password: "password123",
            dealsCount: 86,
            rating: 4.9,
            followingIDs: Set([user2ID])
        ),
        .init(
            id: user2ID,
            displayName: "北区小雪",
            email: "snow@bj.cn",
            password: "password123",
            dealsCount: 42,
            rating: 4.7,
            followingIDs: Set([user1ID, user3ID])
        ),
        .init(
            id: user3ID,
            displayName: "老炮儿滑雪",
            email: "laopao@ski.cn",
            password: "password123",
            dealsCount: 120,
            rating: 5.0,
            followingIDs: []
        )
    ]

    static var sellers: [SnowboardListing.Seller] {
        users.map { user in
            SnowboardListing.Seller(
                id: user.id,
                nickname: user.displayName,
                rating: user.rating,
                dealsCount: user.dealsCount
            )
        }
    }

    static var listings: [SnowboardListing] {
        [
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
    }

    static let listings: [SnowboardListing] = [
        SnowboardListing(
            id: UUID(uuidString: "FDE3B9C1-7339-4B74-923B-68737ACDB031")!,
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
        SnowboardListing(
            id: UUID(uuidString: "1EC45433-ADBB-4EF5-9B96-6CA81E028C69")!,
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
        SnowboardListing(
            id: UUID(uuidString: "5189A957-7078-4FEB-A817-92A164D9E508")!,
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

    static let directThreads: [DirectMessageThread] = [
        .init(
            id: UUID(),
            participantIDs: [user1ID, user2ID],
            messages: [
                .init(id: UUID(), senderID: user1ID, text: "最近准备去崇礼，想约一波吗？", timestamp: Date().addingTimeInterval(-7200)),
                .init(id: UUID(), senderID: user2ID, text: "好呀，周六上午我有空。", timestamp: Date().addingTimeInterval(-3600)),
                .init(id: UUID(), senderID: user1ID, text: "那我提前把板子打蜡，顺便带点装备过去。", timestamp: Date().addingTimeInterval(-1800))
            ]
        )
    ]
}
