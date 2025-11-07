import Foundation

enum SampleData {
    static let sellers: [SnowboardListing.Seller] = [
        .init(id: UUID(), nickname: "板痴阿豪", rating: 4.9, dealsCount: 86),
        .init(id: UUID(), nickname: "北区小雪", rating: 4.7, dealsCount: 42),
        .init(id: UUID(), nickname: "老炮儿滑雪", rating: 5.0, dealsCount: 120)
    ]

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

}
