import Foundation

enum SampleData {
    static let sellers: [SnowboardListing.Seller] = [
        .init(id: UUID(), nickname: "板痴阿豪", rating: 4.9, dealsCount: 86),
        .init(id: UUID(), nickname: "北区小雪", rating: 4.7, dealsCount: 42),
        .init(id: UUID(), nickname: "老炮儿滑雪", rating: 5.0, dealsCount: 120)
    ]

    static let communityUsers: [UserProfile] = [
        .init(
            id: UUID(),
            displayName: "凌风",
            bio: "自由滑粉丝，最爱粉雪沟",
            homeResort: "崇礼·太舞",
            isFollowing: false,
            isFollowingMe: true,
            avatarSymbol: "wind"
        ),
        .init(
            id: UUID(),
            displayName: "雪场向导李教练",
            bio: "国家级单板指导员，每周组织外滑体验",
            homeResort: "吉林·万科",
            isFollowing: true,
            isFollowingMe: true,
            avatarSymbol: "figure.skiing.downhill"
        ),
        .init(
            id: UUID(),
            displayName: "南区小熊",
            bio: "正在准备第一次长白山外滑",
            homeResort: "杭州·云曼",
            isFollowing: false,
            isFollowingMe: false,
            avatarSymbol: "snowflake"
        )
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

    static let demoMessages: [Message] = [
        .init(id: UUID(), sender: .buyer, text: "你好，请问板子还在吗？", timestamp: Date()),
        .init(id: UUID(), sender: .seller, text: "在的，本周末可以在怀北面交。", timestamp: Date().addingTimeInterval(3600)),
        .init(id: UUID(), sender: .buyer, text: "可以小刀到2600吗？", timestamp: Date().addingTimeInterval(7200))
    ]

    static var communityThreads: [UserChatThread] {
        [
            .init(
                id: UUID(),
                user: communityUsers[1],
                messages: [
                    .init(id: UUID(), isCurrentUser: false, text: "周末崇礼外滑还有位置，想一起嘛？", timestamp: Date().addingTimeInterval(-7200)),
                    .init(id: UUID(), isCurrentUser: true, text: "想去！需要准备什么装备吗？", timestamp: Date().addingTimeInterval(-3600)),
                    .init(id: UUID(), isCurrentUser: false, text: "护具齐全就行，车位帮你留一个。", timestamp: Date().addingTimeInterval(-1800))
                ]
            )
        ]
    }

    static var demoGroupRides: [GroupRide] {
        [
            .init(
                id: UUID(),
                organizer: communityUsers[0],
                resortName: "富良野滑雪场",
                resortLocation: "北海道·富良野",
                departureDate: Calendar.current.date(byAdding: .day, value: 10, to: Date()) ?? Date(),
                durationDays: 5,
                participantLimit: 6,
                estimatedCostPerPerson: 6800
            ),
            .init(
                id: UUID(),
                organizer: communityUsers[1],
                resortName: "松花湖滑雪场",
                resortLocation: "吉林·松花湖",
                departureDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
                durationDays: 3,
                participantLimit: 8,
                estimatedCostPerPerson: 3200
            )
        ]
    }
}
