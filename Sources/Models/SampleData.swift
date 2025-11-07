import Foundation

enum SampleData {
    static let sellers: [SnowboardListing.Seller] = [
        .init(id: UUID(uuidString: "2F05C034-3503-4F1A-8574-623AEAE4366A")!, nickname: "板痴阿豪", rating: 4.9, dealsCount: 86),
        .init(id: UUID(uuidString: "F178DD26-7367-495E-9902-B8F9F15F2E15")!, nickname: "北区小雪", rating: 4.7, dealsCount: 42),
        .init(id: UUID(uuidString: "73BB06E3-8095-4474-A061-8C3633F4506F")!, nickname: "老炮儿滑雪", rating: 5.0, dealsCount: 120)
    ]

    static let currentUser: SnowboardListing.Seller = .init(
        id: UUID(uuidString: "BF2A2F20-46F4-4FB3-AFB1-3C79BA98E724")!,
        nickname: "我",
        rating: 5.0,
        dealsCount: 0
    )

    static let currentUserFollowingSellerIDs: Set<UUID> = [
        sellers[0].id
    ]

    static let followersOfCurrentUser: Set<UUID> = [
        sellers[0].id,
        sellers[1].id
    ]

    static let seedListings: [SnowboardListing] = [
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

    private static let referenceDate = Date(timeIntervalSince1970: 1_695_000_000)

    private static let threadIDsBySeller: [UUID: UUID] = [
        sellers[0].id: UUID(uuidString: "6AC70ED5-7F2D-4D70-9DB7-68E4D111E2A4")!,
        sellers[1].id: UUID(uuidString: "5D208B41-05D7-4E03-8D53-3E69F58ED7FD")!
    ]

    private static let messageSeedsBySeller: [UUID: [Message]] = [
        sellers[0].id: [
            Message(
                id: UUID(uuidString: "F3339D57-2A6E-4D63-9E88-6CD0C7048130")!,
                sender: .seller,
                text: "你好！这块板子目前还在，支持怀北面交验货。",
                timestamp: referenceDate
            ),
            Message(
                id: UUID(uuidString: "116CB8C4-08C0-4C43-9C50-707754ED9D3D")!,
                sender: .buyer,
                text: "太好了，本周末能看板吗？",
                timestamp: referenceDate.addingTimeInterval(900)
            ),
            Message(
                id: UUID(uuidString: "A8790F25-6EB8-4597-9E14-24BA69584AD3")!,
                sender: .seller,
                text: "没问题，周六上午十点左右见。",
                timestamp: referenceDate.addingTimeInterval(1500)
            )
        ],
        sellers[1].id: [
            Message(
                id: UUID(uuidString: "2B5F79FD-55DE-47DE-9C28-10F133E6F6A4")!,
                sender: .seller,
                text: "你好～板子状态很好，还送Dakine板包。",
                timestamp: referenceDate.addingTimeInterval(3600)
            ),
            Message(
                id: UUID(uuidString: "57855217-5431-4E6A-A611-9D38E31F0593")!,
                sender: .buyer,
                text: "想问下是否可以快递到上海？",
                timestamp: referenceDate.addingTimeInterval(4200)
            ),
            Message(
                id: UUID(uuidString: "DCBA7A5F-7201-4A3E-B8A7-5A3AAB7954B1")!,
                sender: .seller,
                text: "可以的，顺丰到付没问题。",
                timestamp: referenceDate.addingTimeInterval(4800)
            )
        ]
    ]

    static func messageHistory(for sellerID: UUID) -> [Message] {
        messageSeedsBySeller[sellerID] ?? []
    }

    static func threadIdentifier(for sellerID: UUID) -> UUID? {
        threadIDsBySeller[sellerID]
    }

    static func seedThreads(for listings: [SnowboardListing]) -> [MessageThread] {
        listings.compactMap { listing in
            guard currentUserFollowingSellerIDs.contains(listing.seller.id),
                  followersOfCurrentUser.contains(listing.seller.id),
                  let messages = messageSeedsBySeller[listing.seller.id] else {
                return nil
            }
            return MessageThread(
                id: threadIdentifier(for: listing.seller.id) ?? UUID(),
                listing: listing,
                messages: messages
            )
        }
    }
}
