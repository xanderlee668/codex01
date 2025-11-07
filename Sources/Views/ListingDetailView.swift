import SwiftUI

struct ListingDetailView: View {
    @EnvironmentObject private var marketplace: MarketplaceViewModel
    @State private var localListing: SnowboardListing
    @State private var activeThread: MessageThread?
    @State private var showingFollowAlert = false
    private let listingID: UUID

    init(listing: SnowboardListing) {
        _localListing = State(initialValue: listing)
        listingID = listing.id
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

                SellerCardView(seller: localListing.seller, onChat: openChat)
            }
            .padding()
        }
        .navigationTitle("详情")
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button(action: openChat) {
                    Label("私聊", systemImage: "bubble.left.and.bubble.right.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .opacity(marketplace.canChat(with: localListing.seller) ? 1 : 0.6)
            }
        }
        .sheet(item: $activeThread) { thread in
            MessageThreadView(thread: thread)
                .environmentObject(marketplace)
        }
        .alert("暂无法发起私聊", isPresented: $showingFollowAlert) {
            Button("好的", role: .cancel) { showingFollowAlert = false }
        } message: {
            Text("需要与 \(localListing.seller.nickname) 互相关注后才能开启私聊。")
        }
        .onReceive(marketplace.$listings) { listings in
            guard let updated = listings.first(where: { $0.id == listingID }) else { return }
            localListing = updated
        }
        .onReceive(marketplace.$threads) { threads in
            guard let currentID = activeThread?.id,
                  let updated = threads.first(where: { $0.id == currentID }) else { return }
            activeThread = updated
        }
    }

    private func openChat() {
        if let thread = marketplace.thread(for: localListing) {
            activeThread = thread
        } else {
            showingFollowAlert = true
        }
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
    @EnvironmentObject private var marketplace: MarketplaceViewModel
    let seller: SnowboardListing.Seller
    let onChat: () -> Void

    private var isFollowing: Bool { marketplace.isFollowing(seller) }
    private var sellerFollowsCurrentUser: Bool { marketplace.sellerFollowsCurrentUser(seller) }
    private var canChat: Bool { marketplace.canChat(with: seller) }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.accentColor.opacity(0.15))
                        .frame(width: 56, height: 56)
                    Image(systemName: "person.fill")
                        .font(.title2)
                        .foregroundColor(.accentColor)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(seller.nickname)
                        .font(.headline)
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
                Button {
                    marketplace.toggleFollow(for: seller)
                } label: {
                    Text(isFollowing ? "已关注" : "关注")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(isFollowing ? Color(.systemGray5) : Color.accentColor.opacity(0.2))
                        .foregroundColor(isFollowing ? .primary : .accentColor)
                        .clipShape(Capsule())
                }
            }

            Text("用心挑选器材，只为帮你找到最合适的雪板。支持面交验货，欢迎放心咨询！")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            if canChat {
                Button(action: onChat) {
                    Label("私聊", systemImage: "bubble.left.and.bubble.right.fill")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.top, 4)

                Label("已互相关注，可直接发起私聊", systemImage: "checkmark.seal.fill")
                    .font(.caption)
                    .foregroundColor(.accentColor)
            } else if sellerFollowsCurrentUser {
                Label("对方已关注你，回关即可开通私聊", systemImage: "person.2.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Label("互相关注后即可私聊沟通细节", systemImage: "bubble.left.and.bubble.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct ListingDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ListingDetailView(listing: SampleData.seedListings.first!)
                .environmentObject(MarketplaceViewModel())
        }
    }
}
