import SwiftUI

struct MessagesListView: View {
    @EnvironmentObject private var marketplace: MarketplaceViewModel
    @EnvironmentObject private var auth: AuthViewModel

    private var sortedThreads: [MessageThread] {
        let visibleThreads = marketplace.threads.filter { thread in
            auth.isFollowing(userID: thread.seller.id)
        }

        return visibleThreads.sorted { lhs, rhs in
            let lhsDate = lhs.messages.last?.timestamp ?? .distantPast
            let rhsDate = rhs.messages.last?.timestamp ?? .distantPast
            return lhsDate > rhsDate
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if sortedThreads.isEmpty {
                    EmptyStateView()
                } else {
                    List {
                        ForEach(sortedThreads) { thread in
                            NavigationLink(value: thread) {
                                ConversationRow(thread: thread)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("消息")
            .navigationDestination(for: MessageThread.self) { thread in
                MessageThreadView(thread: thread)
            }
        }
    }
}

private struct ConversationRow: View {
    let thread: MessageThread
    private static let dateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.unitsStyle = .abbreviated
        return formatter
    }()

    private var lastMessage: Message? {
        thread.messages.last
    }

    private var subtitle: String {
        if let listing = thread.listing {
            return listing.title
        }
        return "来自 \(thread.seller.nickname) 的会话"
    }

    private var lastMessagePreview: String {
        lastMessage?.text ?? "暂无消息"
    }

    private var lastMessageTime: String {
        guard let date = lastMessage?.timestamp else { return "" }
        return Self.dateFormatter.localizedString(for: date, relativeTo: Date())
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(Color.accentColor.opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.accentColor)
                )

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline) {
                    Text(thread.seller.nickname)
                        .font(.headline)
                    Spacer()
                    Text(lastMessageTime)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                Text(lastMessagePreview)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 8)
    }
}

private struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "bubble.left.and.exclamationmark.bubble.right")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("还没有会话，去集市找喜欢的雪板开聊吧！")
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

struct MessagesListView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesListView()
            .environmentObject(MarketplaceViewModel())
            .environmentObject(AuthViewModel(currentUser: SampleData.users.first))
    }
}
