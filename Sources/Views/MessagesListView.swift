import Foundation
import SwiftUI

struct MessagesListView: View {
    @EnvironmentObject private var marketplace: MarketplaceViewModel
    @EnvironmentObject private var auth: AuthViewModel
    @State private var selectedThread: MessageThread?

    private var followedSellerIDs: Set<UUID> {
        auth.followedSellerIDs
    }

    private var activeThreads: [MessageThread] {
        marketplace.threads
            .filter { followedSellerIDs.contains($0.seller.id) }
            .sorted { lhs, rhs in
                let lhsDate = lhs.messages.last?.timestamp ?? .distantPast
                let rhsDate = rhs.messages.last?.timestamp ?? .distantPast
                return lhsDate > rhsDate
            }
    }

    private var sellersWithoutThreads: [SnowboardListing.Seller] {
        let activeIDs = Set(activeThreads.map(\.seller.id))
        let remaining = followedSellerIDs.subtracting(activeIDs)

        let sellersFromListings = marketplace.listings.reduce(into: [UUID: SnowboardListing.Seller]()) { partialResult, listing in
            partialResult[listing.seller.id] = listing.seller
        }

        return remaining.compactMap { sellerID in
            if let seller = sellersFromListings[sellerID] {
                return seller
            }
            return auth.user(with: sellerID)?.sellerProfile
        }
        .sorted { lhs, rhs in
            lhs.nickname.localizedCaseInsensitiveCompare(rhs.nickname) == .orderedAscending
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if activeThreads.isEmpty && sellersWithoutThreads.isEmpty {
                    EmptyStateView()
                } else {
                    List {
                        if !activeThreads.isEmpty {
                            Section(header: Text("活跃会话")) {
                                ForEach(activeThreads) { thread in
                                    Button {
                                        selectedThread = thread
                                    } label: {
                                        ConversationRow(thread: thread)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        if !sellersWithoutThreads.isEmpty {
                            Section(header: Text("关注的卖家")) {
                                ForEach(sellersWithoutThreads) { seller in
                                    Button {
                                        let thread = marketplace.thread(with: seller)
                                        selectedThread = thread
                                    } label: {
                                        FollowedSellerRow(seller: seller)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("消息")
            .navigationDestination(item: $selectedThread) { thread in
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

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundColor(.secondary)
                .padding(.top, 6)
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
            Text("关注喜欢的卖家后，就可以在这里开始聊天啦！")
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

private struct FollowedSellerRow: View {
    let seller: SnowboardListing.Seller

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.accentColor.opacity(0.12))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.accentColor)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(seller.nickname)
                    .font(.headline)

                HStack(spacing: 6) {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", seller.rating))
                    }
                    Text("成交 \(seller.dealsCount) 笔")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Text("点我开始聊天")
                    .font(.caption)
                    .foregroundColor(.accentColor)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

struct MessagesListView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesListView()
            .environmentObject(MarketplaceViewModel())
            .environmentObject(AuthViewModel(currentUser: SampleData.users.last))
    }
}
