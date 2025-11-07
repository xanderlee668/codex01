import Foundation

enum SampleData {
    static let marketplaceSellers: [SnowboardListing.Seller] = [
        .init(id: UUID(uuidString: "CFA1442B-0E56-4E19-B27D-DF890E08DA04")!, nickname: "PeakPhoebe", rating: 4.8, dealsCount: 76),
        .init(id: UUID(uuidString: "B6BC0BD0-FB54-48F6-9D56-2D14909A4AC2")!, nickname: "NordicNils", rating: 4.6, dealsCount: 58),
        .init(id: UUID(uuidString: "84FBB0D1-7C1B-4ED5-A9C0-09F2360B117D")!, nickname: "FreerideFiona", rating: 5.0, dealsCount: 134),
        .init(id: UUID(uuidString: "A7E8CF4D-7A8B-4DBA-8C22-0763B025A6C1")!, nickname: "BavarianBen", rating: 4.7, dealsCount: 91)
    ]

    static let accounts: [UserAccount] = [
        UserAccount(
            id: UUID(uuidString: "B8A0AEE0-9A7E-4B7C-A30F-84D4752FC522")!,
            username: "alex",
            password: "ridgepass",
            seller: SnowboardListing.Seller(
                id: UUID(uuidString: "E5B3FF59-7BFA-4F1D-A2D8-8902741760BE")!,
                nickname: "Alex Chambers",
                rating: 4.9,
                dealsCount: 112
            ),
            followingSellerIDs: [marketplaceSellers[0].id, marketplaceSellers[1].id],
            followersOfCurrentUser: [marketplaceSellers[0].id, marketplaceSellers[2].id]
        ),
        UserAccount(
            id: UUID(uuidString: "87D3E9D5-57AB-4F4F-A9B2-4B2A5C43A026")!,
            username: "sofia",
            password: "glacier!",
            seller: SnowboardListing.Seller(
                id: UUID(uuidString: "D9C0B5F3-9C3A-4571-A087-3B7C5C0D5F9A")!,
                nickname: "Sofia Müller",
                rating: 4.7,
                dealsCount: 64
            ),
            followingSellerIDs: [marketplaceSellers[2].id],
            followersOfCurrentUser: [marketplaceSellers[1].id]
        )
    ]

    static let defaultAccount: UserAccount = accounts[0]

    /// Legacy alias kept for earlier call sites that referenced `SampleData.users`.
    /// The app models now treat sellers and users as the same domain object so the
    /// legacy API can surface both registered accounts and pre-seeded marketplace sellers.
    static var users: [SnowboardListing.Seller] {
        accounts.map(\.seller) + marketplaceSellers
    }

    static let seedListings: [SnowboardListing] = [
        SnowboardListing(
            id: UUID(uuidString: "E3B8A37A-8E4C-4E0F-BD7D-AFC65ED0723A")!,
            title: "Jones Stratos 156",
            description: "Versatile all-mountain board tuned for the Alps. Freshly waxed with edges detuned for side hits.",
            condition: .likeNew,
            price: 420,
            location: "Chamonix, France",
            tradeOption: .faceToFace,
            isFavorite: false,
            imageName: "board_blue",
            seller: marketplaceSellers[0]
        ),
        SnowboardListing(
            id: UUID(uuidString: "9F27F21F-1035-4C01-A425-09FB1E3D6B77")!,
            title: "Burton Custom X 158",
            description: "Well-loved freeride setup used for two seasons in Verbier. Includes Burton Cartel bindings.",
            condition: .good,
            price: 360,
            location: "Verbier, Switzerland",
            tradeOption: .hybrid,
            isFavorite: true,
            imageName: "board_red",
            seller: marketplaceSellers[1]
        ),
        SnowboardListing(
            id: UUID(uuidString: "F184CBD5-63F3-4F0F-9E9B-BAE71B9388A4")!,
            title: "Bataleon Distortia 149",
            description: "Playful twin perfect for UK domes and Scottish trips. Minor topsheet scuffs, base freshly repaired.",
            condition: .good,
            price: 295,
            location: "Manchester, United Kingdom",
            tradeOption: .courier,
            isFavorite: false,
            imageName: "board_green",
            seller: marketplaceSellers[2]
        )
    ]

    private static let referenceDate = Date(timeIntervalSince1970: 1_705_000_000)

    private static let threadIDsBySeller: [UUID: UUID] = [
        marketplaceSellers[0].id: UUID(uuidString: "1AF468CC-854C-4E42-8E79-6C8B7F67607E")!,
        marketplaceSellers[1].id: UUID(uuidString: "CEBB7820-09BB-45AF-9D7B-37C4A2B05AD6")!
    ]

    private static let messageSeedsBySeller: [UUID: [Message]] = [
        marketplaceSellers[0].id: [
            Message(
                id: UUID(uuidString: "606F53CB-9472-4FC7-A0C9-0422D8D1B42B")!,
                sender: .seller,
                text: "Hi there! The Stratos is still available and I'm riding Les Grands Montets this weekend if you'd like to try it.",
                timestamp: referenceDate
            ),
            Message(
                id: UUID(uuidString: "F29EAC04-1E5A-4478-9428-BA229FB5C3DE")!,
                sender: .buyer,
                text: "Sounds great. Could we meet Saturday morning at the base station?",
                timestamp: referenceDate.addingTimeInterval(1_200)
            ),
            Message(
                id: UUID(uuidString: "C9B1EB8C-25BF-4EEB-9F5F-1EC24A3A8B97")!,
                sender: .seller,
                text: "Absolutely. I'll bring the board for you to flex around 9:30.",
                timestamp: referenceDate.addingTimeInterval(1_800)
            )
        ],
        marketplaceSellers[1].id: [
            Message(
                id: UUID(uuidString: "F9CBFA61-D05B-4D02-9D26-33F3B1CC7B82")!,
                sender: .seller,
                text: "Hej! Happy to ship the Custom X within Europe. Comes waxed and edges tuned.",
                timestamp: referenceDate.addingTimeInterval(3_600)
            ),
            Message(
                id: UUID(uuidString: "9BCAB790-E59C-4D01-8C88-6C9C6037CE88")!,
                sender: .buyer,
                text: "Could you include the original stomp pad?",
                timestamp: referenceDate.addingTimeInterval(3_900)
            ),
            Message(
                id: UUID(uuidString: "A95E0E84-3F8B-4E85-B44D-B56615BCC275")!,
                sender: .seller,
                text: "Sure thing, I'll add it to the parcel.",
                timestamp: referenceDate.addingTimeInterval(4_200)
            )
        ]
    ]

    static func messageHistory(for sellerID: UUID) -> [Message] {
        messageSeedsBySeller[sellerID] ?? []
    }

    static func threadIdentifier(for sellerID: UUID) -> UUID? {
        threadIDsBySeller[sellerID]
    }

    static func seedThreads(for listings: [SnowboardListing], account: UserAccount) -> [MessageThread] {
        listings.compactMap { listing in
            guard account.followingSellerIDs.contains(listing.seller.id),
                  account.followersOfCurrentUser.contains(listing.seller.id),
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
