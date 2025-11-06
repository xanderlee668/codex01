import SwiftUI

struct ListingDetailView: View {
    @EnvironmentObject private var marketplace: MarketplaceViewModel
    @EnvironmentObject private var auth: AuthViewModel
    @State private var showingMessageSheet = false
    @State private var localListing: SnowboardListing
    private let listingID: UUID

    init(listing: SnowboardListing) {
        _localListing = State(initialValue: listing)
        listingID = listing.id
    }

    private var sellerUser: User? {
        auth.user(with: localListing.seller.id)
    }

    private var canFollowSeller: Bool {
        guard let seller = sellerUser else { return false }
        guard let current = auth.currentUser else { return false }
        return current.id != seller.id
    }

    private var isFollowingSeller: Bool {
        guard let seller = sellerUser else { return false }
        return auth.isFollowing(userID: seller.id)
    }

    private var canMessageSeller: Bool {
        isFollowingSeller && sellerUser != nil
    }

    private func toggleFollow() {
        if let seller = sellerUser {
            auth.toggleFollow(userID: seller.id)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(LinearGradient(colors: [.blue.opacity(0.6), .purple.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 220)
                    .overlay(
                        Image(systemName: "snowboard")
                            .font(.system(size: 80))
                            .foregroundColor(.white.opacity(0.9))
                    )
                    .shadow(radius: 8)

                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(localListing.title)
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text(localListing.condition.rawValue)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button {
                            marketplace.toggleFavorite(for: localListing)
                            localListing.isFavorite.toggle()
                        } label: {
                            Label(
                                localListing.isFavorite ? "已收藏" : "收藏",
                                systemImage: localListing.isFavorite ? "heart.fill" : "heart"
                            )
                            .labelStyle(.iconOnly)
                            .padding(10)
                            .background(Color(.systemGray6))
                            .clipShape(Circle())
                        }
                    }

                    Text(localListing.description)
                        .font(.body)
                        .foregroundColor(.primary)

                    Divider()

                    InfoRow(icon: "mappin.circle", title: "交易地点", value: localListing.location)
                    InfoRow(icon: "shippingbox", title: "交易方式", value: localListing.tradeOption.rawValue)
                    InfoRow(icon: "tag", title: "价格", value: localListing.formattedPrice)
                }
                .padding()
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                SellerCardView(
                    seller: localListing.seller,
                    canFollow: sellerUser != nil && !isOwnListing,
                    isFollowing: sellerUser.flatMap { auth.isFollowing(userID: $0.id) } ?? false,
                    isMutual: sellerUser.flatMap { auth.isMutualFollow(with: $0.id) } ?? false,
                    followAction: {
                        guard let sellerUser = sellerUser else { return }
                        auth.toggleFollow(userID: sellerUser.id)
                    }
                )
            }
            .padding(.top)
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
        .navigationTitle("详情")
        .toolbar {
            if sellerUser != nil && !isOwnListing {
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        showingMessageSheet = true
                    } label: {
                        Label("私信沟通", systemImage: "message")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!canOpenChat)
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .background(.thinMaterial)
        }
        .sheet(isPresented: $showingMessageSheet) {
            if let sellerUser = sellerUser, let thread = auth.directThread(with: sellerUser.id) {
                DirectChatView(partner: sellerUser, thread: thread)
                    .environmentObject(auth)
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.secondary)
                    Text("互相关注后才能开启私聊")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
        }
        .onReceive(marketplace.$listings) { listings in
            guard let updated = listings.first(where: { $0.id == listingID }) else { return }
            localListing = updated
        }
    }

    private var sellerUser: User? {
        auth.user(with: localListing.seller.id)
    }

    private var isOwnListing: Bool {
        guard let currentUser = auth.currentUser else { return false }
        return currentUser.id == localListing.seller.id
    }

    private var canOpenChat: Bool {
        guard let sellerUser = sellerUser else { return false }
        return auth.isMutualFollow(with: sellerUser.id)
    }
}

private struct InfoRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack {
            Label(title, systemImage: icon)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.body)
        }
        .font(.subheadline)
    }
}

private struct SellerCardView: View {
    let seller: SnowboardListing.Seller
    let canFollow: Bool
    let isFollowing: Bool
    let isMutual: Bool
    let followAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(width: 56, height: 56)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(seller.nickname)
                        .font(.headline)
                Button(action: onTap) {
                    Circle()
                        .fill(Color.accentColor.opacity(0.15))
                        .frame(width: 56, height: 56)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.title2)
                                .foregroundColor(.accentColor)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("联系\(seller.nickname)")

                VStack(alignment: .leading, spacing: 4) {
                    Button(action: onTap) {
                        Text(seller.nickname)
                            .font(.headline)
                            .foregroundColor(.accentColor)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("向\(seller.nickname)发送消息")

                    HStack(spacing: 6) {
                        Label(String(format: "%.1f", seller.rating), systemImage: "star.fill")
                            .labelStyle(.titleAndIcon)
                            .foregroundColor(.yellow)
                        Text("成交 \(seller.dealsCount) 笔")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                if canFollow {
                    Button(action: onToggleFollow) {
                        Label(isFollowing ? "已关注" : "关注", systemImage: isFollowing ? "checkmark" : "plus")
                            .font(.subheadline)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(isFollowing ? Color(.systemGray5) : Color.accentColor.opacity(0.2))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }

            Text("用心挑选器材，只为帮你找到最合适的雪板。支持面交验货，欢迎放心咨询！")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            if canFollow {
                Button(action: followAction) {
                    Label(
                        isFollowing ? "已关注" : "关注卖家",
                        systemImage: isFollowing ? "checkmark.circle.fill" : "person.badge.plus"
                    )
                    .font(.headline)
                }
                .buttonStyle(.borderedProminent)
                .tint(isFollowing ? .green : .accentColor)

                Label(
                    isMutual ? "已互相关注，可直接私聊" : (isFollowing ? "对方尚未回关，暂无法私聊" : "互相关注后可开启私聊"),
                    systemImage: isMutual ? "bubble.left.and.bubble.right.fill" : "lock"
                )
                .font(.caption)
                .foregroundColor(isMutual ? .green : .secondary)
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}

struct ListingDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ListingDetailView(listing: SampleData.listings.first!)
                .environmentObject(MarketplaceViewModel())
                .environmentObject(AuthViewModel(currentUser: SampleData.users.first))
        }
    }
}
