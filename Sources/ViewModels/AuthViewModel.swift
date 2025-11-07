import Foundation
import Combine

final class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool
    let marketplace: MarketplaceViewModel

    init(
        isAuthenticated: Bool = true,
        marketplace: MarketplaceViewModel = MarketplaceViewModel()
    ) {
        self.isAuthenticated = isAuthenticated
        self.marketplace = marketplace
    }

    func signIn() {
        isAuthenticated = true
    }

    func signOut() {
        isAuthenticated = false
    }
}
