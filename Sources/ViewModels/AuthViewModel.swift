import Combine
import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    @Published private(set) var registeredUsers: [User]
    @Published var currentUser: User?
    @Published var errorMessage: String?
    @Published private var followingMap: [UUID: Set<UUID>]

    init(users: [User] = SampleData.users, currentUser: User? = nil, followingMap: [UUID: Set<UUID>] = SampleData.defaultFollowingMap) {
        self.registeredUsers = users
        self.currentUser = currentUser
        self.followingMap = followingMap
    }

    func login(email: String, password: String) {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty else {
            errorMessage = "请输入邮箱"
            return
        }
        guard let user = registeredUsers.first(where: { $0.email.caseInsensitiveCompare(trimmedEmail) == .orderedSame }) else {
            errorMessage = "账号不存在"
            return
        }
        guard user.password == password else {
            errorMessage = "密码错误"
            return
        }
        currentUser = user
        errorMessage = nil
    }

    @discardableResult
    func register(displayName: String, email: String, password: String, confirmPassword: String) -> Bool {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            errorMessage = "请填写昵称"
            return false
        }
        guard !trimmedEmail.isEmpty else {
            errorMessage = "请填写邮箱"
            return false
        }
        guard password == confirmPassword else {
            errorMessage = "两次输入的密码不一致"
            return false
        }
        guard password.count >= 6 else {
            errorMessage = "密码至少6位"
            return false
        }
        guard !registeredUsers.contains(where: { $0.email.caseInsensitiveCompare(trimmedEmail) == .orderedSame }) else {
            errorMessage = "该邮箱已注册"
            return false
        }

        let newUser = User(
            id: UUID(),
            displayName: trimmedName,
            email: trimmedEmail,
            password: password,
            dealsCount: 0,
            rating: 5.0
        )
        registeredUsers.append(newUser)
        followingMap[newUser.id] = []
        currentUser = newUser
        errorMessage = nil
        return true
    }

    func logout() {
        currentUser = nil
        errorMessage = nil
    }

    func user(with id: UUID) -> User? {
        registeredUsers.first { $0.id == id }
    }

    var followedSellerIDs: Set<UUID> {
        guard let currentID = currentUser?.id else { return [] }
        return followingMap[currentID] ?? []
    }

    func isFollowing(userID: UUID) -> Bool {
        guard let currentID = currentUser?.id, currentID != userID else { return false }
        return followingMap[currentID, default: []].contains(userID)
    }

    func toggleFollow(userID: UUID) {
        guard let currentID = currentUser?.id, currentID != userID else { return }
        var relations = followingMap[currentID, default: []]
        if relations.contains(userID) {
            relations.remove(userID)
        } else {
            relations.insert(userID)
        }
        followingMap[currentID] = relations
    }
}
