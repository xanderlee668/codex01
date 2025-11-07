import Foundation
import Combine

final class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var authError: String? = nil
    @Published private(set) var accounts: [UserAccount] = []
    @Published private(set) var currentAccount: UserAccount? = nil

    let marketplace: MarketplaceViewModel

    var currentUser: SnowboardListing.Seller? {
        currentAccount?.seller
    }

    init(
        accounts: [UserAccount] = SampleData.accounts,
        initialAccount: UserAccount? = nil,
        isAuthenticated: Bool = false
    ) {
        let fallbackSeller = SampleData.marketplaceSellers.first ?? SnowboardListing.Seller(
            id: UUID(),
            nickname: "Rider",
            rating: 0,
            dealsCount: 0
        )
        let fallbackAccount = UserAccount(
            id: UUID(),
            username: "demo",
            password: "",
            seller: fallbackSeller,
            followingSellerIDs: [],
            followersOfCurrentUser: []
        )

        if accounts.isEmpty {
            self.accounts = [fallbackAccount]
        } else {
            self.accounts = accounts
        }

        let resolvedAccount = initialAccount ?? self.accounts.first ?? fallbackAccount
        self.marketplace = MarketplaceViewModel(account: resolvedAccount)
        self.isAuthenticated = isAuthenticated
        if isAuthenticated {
            currentAccount = resolvedAccount
        } else {
            currentAccount = nil
        }
    }

    func signIn(username: String, password: String) {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedUsername.isEmpty, !password.isEmpty else {
            authError = "Please enter your username and password."
            return
        }

        guard let index = accounts.firstIndex(where: { $0.username.lowercased() == trimmedUsername.lowercased() }) else {
            authError = "No account matches that username."
            return
        }

        let account = accounts[index]
        guard account.password == password else {
            authError = "Incorrect password."
            return
        }

        authError = nil
        currentAccount = account
        marketplace.configure(with: account)
        isAuthenticated = true
    }

    func register(username: String, password: String, displayName: String) {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDisplayName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmedUsername.count >= 3 else {
            authError = "Usernames need at least 3 characters."
            return
        }

        guard password.count >= 6 else {
            authError = "Passwords need at least 6 characters."
            return
        }

        guard !accounts.contains(where: { $0.username.lowercased() == trimmedUsername.lowercased() }) else {
            authError = "That username is already taken."
            return
        }

        let nickname = trimmedDisplayName.isEmpty ? trimmedUsername : trimmedDisplayName
        let newAccount = UserAccount(
            id: UUID(),
            username: trimmedUsername,
            password: password,
            seller: SnowboardListing.Seller(
                id: UUID(),
                nickname: nickname,
                rating: 5.0,
                dealsCount: 0
            ),
            followingSellerIDs: [],
            followersOfCurrentUser: []
        )

        accounts.append(newAccount)
        authError = nil
        currentAccount = newAccount
        marketplace.configure(with: newAccount)
        isAuthenticated = true
    }

    func signOut() {
        isAuthenticated = false
        currentAccount = nil
        authError = nil
    }
}
