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
            followersOfCurrentUser: [],
            email: "demo@snowboardswap.app",
            location: "Chamonix, France",
            bio: "Always chasing powder days."
        )

        let resolvedAccounts: [UserAccount]
        if accounts.isEmpty {
            resolvedAccounts = [fallbackAccount]
        } else {
            resolvedAccounts = accounts
        }

        self.accounts = resolvedAccounts

        let resolvedAccount = initialAccount ?? resolvedAccounts.first ?? fallbackAccount
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
            followersOfCurrentUser: [],
            email: "\(trimmedUsername)@snowboardswap.app",
            location: "",
            bio: ""
        )

        accounts.append(newAccount)
        authError = nil
        currentAccount = newAccount
        marketplace.configure(with: newAccount)
        isAuthenticated = true
    }

    enum ProfileUpdateError: LocalizedError {
        case noActiveAccount
        case emptyDisplayName
        case invalidEmail

        var errorDescription: String? {
            switch self {
            case .noActiveAccount:
                return "No active account to update."
            case .emptyDisplayName:
                return "Display name cannot be empty."
            case .invalidEmail:
                return "Enter a valid email address."
            }
        }
    }

    enum PasswordChangeError: LocalizedError {
        case noActiveAccount
        case incorrectCurrentPassword
        case passwordsDoNotMatch
        case weakPassword

        var errorDescription: String? {
            switch self {
            case .noActiveAccount:
                return "No active account to update."
            case .incorrectCurrentPassword:
                return "Current password is incorrect."
            case .passwordsDoNotMatch:
                return "New passwords do not match."
            case .weakPassword:
                return "New password must be at least 6 characters."
            }
        }
    }

    func updateProfile(
        displayName: String,
        email: String,
        location: String,
        bio: String
    ) -> Result<Void, ProfileUpdateError> {
        guard var account = currentAccount else { return .failure(.noActiveAccount) }

        let trimmedDisplayName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedDisplayName.isEmpty else { return .failure(.emptyDisplayName) }

        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedEmail.contains("@"), trimmedEmail.contains(".") else {
            return .failure(.invalidEmail)
        }

        account.seller.nickname = trimmedDisplayName
        account.email = trimmedEmail
        account.location = location.trimmingCharacters(in: .whitespacesAndNewlines)
        account.bio = bio.trimmingCharacters(in: .whitespacesAndNewlines)

        persist(account)
        return .success(())
    }

    func changePassword(
        currentPassword: String,
        newPassword: String,
        confirmPassword: String
    ) -> Result<Void, PasswordChangeError> {
        guard var account = currentAccount else { return .failure(.noActiveAccount) }
        guard account.password == currentPassword else { return .failure(.incorrectCurrentPassword) }
        guard newPassword == confirmPassword else { return .failure(.passwordsDoNotMatch) }
        guard newPassword.count >= 6 else { return .failure(.weakPassword) }

        account.password = newPassword
        persist(account)
        return .success(())
    }

    func signOut() {
        isAuthenticated = false
        currentAccount = nil
        authError = nil
    }

    private func persist(_ account: UserAccount) {
        guard let index = accounts.firstIndex(where: { $0.id == account.id }) else { return }
        accounts[index] = account
        currentAccount = account
        marketplace.updateCurrentAccount(account)
    }
}
