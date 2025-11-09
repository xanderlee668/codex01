import Foundation
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var authError: String? = nil
    @Published private(set) var currentAccount: UserAccount? = nil
    @Published private(set) var marketplace: MarketplaceViewModel? = nil

    private let apiClient: APIClient
    private var restoreTask: Task<Void, Never>? = nil

    init(apiClient: APIClient = APIClient(), restoreSessionOnLaunch: Bool = true) {
        self.apiClient = apiClient

        if restoreSessionOnLaunch {
            restoreTask = Task { await restoreSession() }
        }
    }

    deinit {
        restoreTask?.cancel()
    }

    func signIn(email: String, password: String) async {
        // 对应后端登录接口：POST /api/auth/login。
        // 输入邮箱 + 密码，成功会收到 JWT 与用户信息。
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !password.isEmpty
        else {
            authError = "Please enter your email and password."
            return
        }

        do {
            let session = try await apiClient.login(email: email, password: password)
            apply(session: session)
        } catch {
            authError = error.localizedDescription
        }
    }

    func register(email: String, password: String, displayName: String) async {
        // 对应后端注册接口：POST /api/auth/register。
        // 注册成功后立即沿用后端返回的 token 进入登录态。
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDisplayName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmedEmail.contains("@") else {
            authError = "Enter a valid email address."
            return
        }

        guard password.count >= 6 else {
            authError = "Passwords need at least 6 characters."
            return
        }

        guard !trimmedDisplayName.isEmpty else {
            authError = "Display name is required."
            return
        }

        do {
            let session = try await apiClient.register(
                email: trimmedEmail,
                password: password,
                displayName: trimmedDisplayName
            )
            apply(session: session)
        } catch {
            authError = error.localizedDescription
        }
    }

    func signOut() {
        apiClient.logout()
        currentAccount = nil
        marketplace = nil
        isAuthenticated = false
        authError = nil
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

        currentAccount = account
        marketplace?.configure(with: account)
        return .success(())
    }

    func changePassword(
        currentPassword: String,
        newPassword: String,
        confirmPassword: String
    ) -> Result<Void, PasswordChangeError> {
        guard currentAccount != nil else { return .failure(.noActiveAccount) }
        guard !currentPassword.isEmpty else { return .failure(.incorrectCurrentPassword) }
        guard newPassword == confirmPassword else { return .failure(.passwordsDoNotMatch) }
        guard newPassword.count >= 6 else { return .failure(.weakPassword) }
        return .success(())
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

    private func apply(session: APIClient.AuthSession) {
        // 将后端返回的 AuthSession 转换成前端的 UserAccount，
        // 并初始化关联的 MarketplaceViewModel。
        authError = nil
        let account = mapToAccount(session.user)
        currentAccount = account
        if let marketplace {
            marketplace.configure(with: account)
        } else {
            marketplace = MarketplaceViewModel(account: account, apiClient: apiClient)
        }
        isAuthenticated = true
    }

    private func restoreSession() async {
        // App 冷启动时调用 GET /api/auth/me，
        // 若后端校验 JWT 成功则自动恢复登录状态。
        do {
            guard let user = try await apiClient.fetchCurrentUser() else {
                return
            }
            await MainActor.run {
                let account = mapToAccount(user)
                currentAccount = account
                marketplace = MarketplaceViewModel(account: account, apiClient: apiClient)
                isAuthenticated = true
            }
        } catch {
            await MainActor.run {
                authError = error.localizedDescription
            }
        }
    }

    private func mapToAccount(_ user: APIClient.AuthenticatedUser) -> UserAccount {
        // 后端需要在 AuthResponse.user 中返回 display_name、rating 等字段，
        // 对应 UserAccount/Seller 的属性才能正确显示。
        let seller = SnowboardListing.Seller(
            id: user.userID,
            nickname: user.displayName,
            rating: user.rating,
            dealsCount: user.dealsCount
        )

        return UserAccount(
            id: user.userID,
            username: user.email,
            password: "",
            seller: seller,
            followingSellerIDs: [],
            followersOfCurrentUser: [],
            email: user.email,
            location: user.location,
            bio: user.bio
        )
    }
}

#if DEBUG
extension AuthViewModel {
    static func previewAuthenticated() -> AuthViewModel {
        let apiClient = APIClient()
        let model = AuthViewModel(apiClient: apiClient, restoreSessionOnLaunch: false)
        let account = SampleData.accounts.first ?? SampleData.defaultAccount
        model.currentAccount = account
        model.isAuthenticated = true
        let marketplace = MarketplaceViewModel(account: account, apiClient: apiClient, autoRefresh: false)
        marketplace.listings = SampleData.seedListings
        marketplace.groupTrips = SampleData.seedTrips(for: account)
        marketplace.tripThreads = SampleData.seedTripThreads(for: marketplace.groupTrips, account: account)
        model.marketplace = marketplace
        return model
    }

    static func previewUnauthenticated() -> AuthViewModel {
        AuthViewModel(restoreSessionOnLaunch: false)
    }
}
#endif
