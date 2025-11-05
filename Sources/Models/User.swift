import Foundation

struct User: Identifiable, Equatable {
    let id: UUID
    var displayName: String
    var email: String
    var password: String
    var dealsCount: Int
    var rating: Double

    var sellerProfile: SnowboardListing.Seller {
        SnowboardListing.Seller(
            id: id,
            nickname: displayName,
            rating: rating,
            dealsCount: dealsCount
        )
    }
}
