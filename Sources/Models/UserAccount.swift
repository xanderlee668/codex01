import Foundation

struct UserAccount: Identifiable, Hashable {
    let id: UUID
    var username: String
    var password: String
    var seller: SnowboardListing.Seller
    var followingSellerIDs: Set<UUID>
    var followersOfCurrentUser: Set<UUID>
    var email: String = ""
    var location: String = ""
    var bio: String = ""
}
