import Combine
import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    @Published private(set) var registeredUsers: [User]
    @Published var currentUser: User?
    @Published var errorMessage: String?
    @Published private(set) var directThreads: [DirectMessageThread]

    init(users: [User] = SampleData.users,
         directThreads: [DirectMessageThread] = SampleData.directThreads,
         currentUser: User? = nil) {
        self.registeredUsers = users
        self.directThreads = directThreads
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
            rating: 5.0,
            followingIDs: []
        )
        registeredUsers.append(newUser)
        currentUser = newUser
        errorMessage = nil
        return true
    }

    func logout() {
        currentUser = nil
        errorMessage = nil
    }

    func user(with id: UUID) -> User? {
        registeredUsers.first(where: { $0.id == id })
    }

    func isFollowing(userID: UUID) -> Bool {
        guard let currentUser else { return false }
        return currentUser.followingIDs.contains(userID)
    }

    func isMutualFollow(with userID: UUID) -> Bool {
        guard let currentUser else { return false }
        guard let otherUser = user(with: userID) else { return false }
        return currentUser.followingIDs.contains(userID) && otherUser.followingIDs.contains(currentUser.id)
    }

    func toggleFollow(userID: UUID) {
        guard var currentUser = currentUser else { return }
        guard currentUser.id != userID else { return }

        if currentUser.followingIDs.contains(userID) {
            currentUser.followingIDs.remove(userID)
        } else {
            currentUser.followingIDs.insert(userID)
        }

        persist(user: currentUser)
    }

    func directThread(with userID: UUID) -> DirectMessageThread? {
        guard let currentUser else { return nil }
        let participants: Set<UUID> = [currentUser.id, userID]
        if let index = directThreads.firstIndex(where: { $0.participantIDs == participants }) {
            return directThreads[index]
        }
        let thread = DirectMessageThread(id: UUID(), participantIDs: participants)
        directThreads.append(thread)
        return thread
    }

    @discardableResult
    func sendDirectMessage(_ text: String, in thread: DirectMessageThread) -> DirectMessage? {
        guard let currentUser else { return nil }
        guard let index = directThreads.firstIndex(where: { $0.id == thread.id }) else { return nil }
        let message = DirectMessage(id: UUID(), senderID: currentUser.id, text: text, timestamp: Date())
        directThreads[index].messages.append(message)
        return message
    }

    private func persist(user: User) {
        if let index = registeredUsers.firstIndex(where: { $0.id == user.id }) {
            registeredUsers[index] = user
        }
        if currentUser?.id == user.id {
            currentUser = user
        }
    }
}
