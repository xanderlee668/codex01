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

    private static let arlbergTripID = UUID(uuidString: "D813F1B0-36C5-4E3C-A91C-1B9DF37F7E04")!
    private static let laaxTripID = UUID(uuidString: "3AD2C8D0-1B1C-4E8F-A7F3-3322466DB05D")!
    private static let lofotenTripID = UUID(uuidString: "A71988C8-E60C-45EA-8C2F-6A59F0AC0133")!

    private static let baseTripSeeds: [GroupTrip] = [
        GroupTrip(
            id: arlbergTripID,
            title: "Arlberg Powder Weekend",
            resort: "St. Anton am Arlberg, Austria",
            departureLocation: "Innsbruck, Austria",
            startDate: referenceDate.addingTimeInterval(86_400 * 10),
            participantRange: 4...8,
            estimatedCostPerPerson: 320,
            description: "Chasing fresh snow around the Arlberg region with avalanche gear checks and shared ride from Innsbruck.",
            organizer: accounts[0].seller,
            approvedParticipantIDs: Set([marketplaceSellers[2].id]),
            pendingRequests: [
                GroupTrip.JoinRequest(
                    id: UUID(uuidString: "D873B021-E612-4F98-A1F7-39AA02AC47B1")!,
                    applicant: marketplaceSellers[1],
                    requestedAt: referenceDate.addingTimeInterval(7_200)
                )
            ]
        ),
        GroupTrip(
            id: laaxTripID,
            title: "Freestyle Progression in Laax",
            resort: "Laax, Switzerland",
            departureLocation: "Zurich, Switzerland",
            startDate: referenceDate.addingTimeInterval(86_400 * 21),
            participantRange: 3...6,
            estimatedCostPerPerson: 450,
            description: "Park laps with a local coach, shared accommodation in Flims, and optional avalanche awareness refresher.",
            organizer: marketplaceSellers[0],
            approvedParticipantIDs: Set([accounts[0].seller.id]),
            pendingRequests: []
        ),
        GroupTrip(
            id: lofotenTripID,
            title: "Lofoten Splitboard Adventure",
            resort: "Lofoten Islands, Norway",
            departureLocation: "Tromsø, Norway",
            startDate: referenceDate.addingTimeInterval(86_400 * 35),
            participantRange: 5...7,
            estimatedCostPerPerson: 780,
            description: "Week-long splitboard touring with boat transfers, guiding, and shared cabin lodging on the fjords.",
            organizer: accounts[1].seller,
            approvedParticipantIDs: [] as Set<UUID>,
            pendingRequests: []
        )
    ]

    private static let tripThreadIDs: [UUID: UUID] = [
        arlbergTripID: UUID(uuidString: "2F854BD6-5E61-4469-A340-612EE52E7B42")!,
        laaxTripID: UUID(uuidString: "6A0B103C-8B6A-4F54-8E74-5B15B6CB7111")!
    ]

    private static let groupTripMessageSeeds: [UUID: [GroupTripMessage]] = [
        arlbergTripID: [
            GroupTripMessage(
                id: UUID(uuidString: "F65E6C83-5D33-4AA5-9341-1DB1CF629717")!,
                senderID: accounts[0].seller.id,
                senderName: accounts[0].seller.nickname,
                role: .organizer,
                text: "Welcome aboard! We'll meet at Innsbruck Hauptbahnhof at 06:30 on Saturday to load the van.",
                timestamp: referenceDate.addingTimeInterval(9_000)
            ),
            GroupTripMessage(
                id: UUID(uuidString: "7E48D32C-2D26-4C86-9281-E4DE1F24C55F")!,
                senderID: marketplaceSellers[2].id,
                senderName: marketplaceSellers[2].nickname,
                role: .participant,
                text: "I'll bring the spare avalanche kit and radio set just in case anyone needs it.",
                timestamp: referenceDate.addingTimeInterval(9_600)
            )
        ],
        laaxTripID: [
            GroupTripMessage(
                id: UUID(uuidString: "8B32EE38-43F5-4E04-BEB0-5C0C5FB4A95E")!,
                senderID: marketplaceSellers[0].id,
                senderName: marketplaceSellers[0].nickname,
                role: .organizer,
                text: "Stoked to have you join! We'll warm up on P60 before hitting the pro line. Helmets mandatory.",
                timestamp: referenceDate.addingTimeInterval(42_000)
            ),
            GroupTripMessage(
                id: UUID(uuidString: "5334B4B2-CC5E-48FB-B994-7C0DA7B43C50")!,
                senderID: accounts[0].seller.id,
                senderName: accounts[0].seller.nickname,
                role: .participant,
                text: "Perfect. I'll book the train from Zurich to Chur and meet you all Friday evening.",
                timestamp: referenceDate.addingTimeInterval(43_200)
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

    static func seedTrips(for account: UserAccount) -> [GroupTrip] {
        baseTripSeeds.map { trip in
            var trip = trip
            if trip.organizer.id == account.seller.id {
                return trip
            }
            if trip.approvedParticipantIDs.contains(account.seller.id) {
                return trip
            }
            // Keep pending requests from other riders but ensure duplicates aren't introduced
            trip.pendingRequests.removeAll(where: { $0.applicant.id == account.seller.id })
            return trip
        }
    }

    static func tripThreadIdentifier(for tripID: UUID) -> UUID? {
        tripThreadIDs[tripID]
    }

    static func tripMessages(for tripID: UUID) -> [GroupTripMessage] {
        groupTripMessageSeeds[tripID] ?? []
    }

    static func seedTripThreads(for trips: [GroupTrip], account: UserAccount) -> [GroupTripThread] {
        trips.compactMap { trip in
            guard trip.includesParticipant(account.seller) else { return nil }
            let threadID = tripThreadIdentifier(for: trip.id) ?? UUID()
            let messages = tripMessages(for: trip.id)
            return GroupTripThread(id: threadID, tripID: trip.id, messages: messages)
        }
    }
}
