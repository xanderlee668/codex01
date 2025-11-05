import Foundation

final class SocialViewModel: ObservableObject {
    @Published var users: [UserProfile]
    @Published var threads: [UserChatThread]

    init(users: [UserProfile] = SampleData.communityUsers,
         threads: [UserChatThread] = SampleData.communityThreads) {
        self.users = users
        self.threads = threads
        synchronizeThreadUsers()
    }

    func toggleFollow(for user: UserProfile) {
        guard let index = users.firstIndex(where: { $0.id == user.id }) else { return }
        users[index].isFollowing.toggle()
        let updatedUser = users[index]

        if let threadIndex = threads.firstIndex(where: { $0.user.id == updatedUser.id }) {
            if updatedUser.canChat {
                threads[threadIndex].user = updatedUser
            } else {
                threads.remove(at: threadIndex)
            }
        } else if updatedUser.canChat {
            let welcome = UserChatMessage(
                id: UUID(),
                isCurrentUser: false,
                text: "很高兴互相关注，有空一起去滑雪！",
                timestamp: Date()
            )
            let thread = UserChatThread(id: UUID(), user: updatedUser, messages: [welcome])
            threads.append(thread)
        }
    }

    func thread(for userID: UUID) -> UserChatThread? {
        threads.first(where: { $0.user.id == userID })
    }

    @discardableResult
    func sendMessage(_ text: String, in thread: UserChatThread) -> UserChatMessage? {
        guard let index = threads.firstIndex(where: { $0.id == thread.id }) else { return nil }
        let message = UserChatMessage(id: UUID(), isCurrentUser: true, text: text, timestamp: Date())
        threads[index].messages.append(message)
        return message
    }

    func refreshThreadUser(with user: UserProfile) {
        guard let index = threads.firstIndex(where: { $0.user.id == user.id }) else { return }
        threads[index].user = user
    }

    private func synchronizeThreadUsers() {
        for idx in threads.indices {
            if let updatedUser = users.first(where: { $0.id == threads[idx].user.id }) {
                threads[idx].user = updatedUser
            }
        }
    }
}
