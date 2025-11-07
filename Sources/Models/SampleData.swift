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
}
