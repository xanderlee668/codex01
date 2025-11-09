import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct ListingDetailView: View {
    @EnvironmentObject private var marketplace: MarketplaceViewModel
    @State private var localListing: SnowboardListing
    @State private var activeThread: MessageThread?
    @State private var showingFollowAlert = false
    @State private var followAlertMessage: String?
    private let listingID: UUID

    init(listing: SnowboardListing) {
        _localListing = State(initialValue: listing)
        listingID = listing.id
    }

    /// Legacy initializer kept for compatibility with older call sites that
    /// still pass the current user when presenting the detail view. The view
    /// no longer relies on that value, so we simply forward to the primary
    /// initializer while accepting optional values to cover more legacy usages.
    @available(*, deprecated, message: "Use init(listing:) instead.")
    init(listing: SnowboardListing, currentUser: SnowboardListing.Seller? = nil) {
        self.init(listing: listing)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if !localListing.photos.isEmpty {
                    // 详情页顶部轮播，展示所有上传的照片
                    ListingPhotoCarousel(photos: localListing.photos)
                        .frame(height: 260)
                        .transition(.opacity)
                } else {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(LinearGradient(colors: [.blue.opacity(0.6), .purple.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(height: 220)
                        .overlay(
                            Image(systemName: "snowboard")
                                .font(.system(size: 80))
                                .foregroundColor(.white.opacity(0.9))
                        )
                        .shadow(radius: 8)
                }

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
                            localListing.isFavorite ? "Saved" : "Save",
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

                    InfoRow(icon: "mappin.circle", title: "Location", value: localListing.location)
                    InfoRow(icon: "shippingbox", title: "Trade option", value: localListing.tradeOption.rawValue)
                    InfoRow(icon: "tag", title: "Price", value: localListing.formattedPrice)
                }
                .padding()
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                SellerCardView(seller: localListing.seller, onChat: openChat)
            }
            .padding()
        }
        .navigationTitle("Details")
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button(action: openChat) {
                    Label("Message", systemImage: "bubble.left.and.bubble.right.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .opacity(chatStatus.canOpenThread ? 1 : 0.6)
            }
        }
        .sheet(item: $activeThread) { thread in
            MessageThreadView(thread: thread)
                .environmentObject(marketplace)
        }
        .alert("Messaging unavailable", isPresented: $showingFollowAlert) {
            Button("OK", role: .cancel) { showingFollowAlert = false }
        } message: {
            Text(followAlertMessage ?? "Follow \(localListing.seller.nickname) back to unlock messaging.")
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

    private var chatStatus: MarketplaceViewModel.ChatStatus {
        marketplace.chatStatus(with: localListing.seller)
    }

    private func openChat() {
        followAlertMessage = nil
        switch chatStatus {
        case .available:
            if let thread = marketplace.thread(for: localListing) {
                activeThread = thread
            }
        case .awaitingCurrentUserFollowBack:
            followAlertMessage = "This rider already follows you—follow back to start chatting."
            showingFollowAlert = true
        case .awaitingMutualFollow:
            followAlertMessage = "Follow each other before messaging \(localListing.seller.nickname)."
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
    private var chatStatus: MarketplaceViewModel.ChatStatus { marketplace.chatStatus(with: seller) }

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
                        Text("Completed \(seller.dealsCount) trades")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                Button {
                    marketplace.toggleFollow(for: seller)
                } label: {
                    Text(isFollowing ? "Following" : "Follow")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(isFollowing ? Color(.systemGray5) : Color.accentColor.opacity(0.2))
                        .foregroundColor(isFollowing ? .primary : .accentColor)
                        .clipShape(Capsule())
                }
            }

            Text("Curated European gear, inspected and ready for your next trip. Happy to answer any questions!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            if chatStatus.canOpenThread {
                Button(action: onChat) {
                    Label("Message", systemImage: "bubble.left.and.bubble.right.fill")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.top, 4)

                Label("Mutual follow active—feel free to chat", systemImage: "checkmark.seal.fill")
                    .font(.caption)
                    .foregroundColor(.accentColor)
            } else if chatStatus == .awaitingCurrentUserFollowBack {
                Label("They already follow you—follow back to unlock chat", systemImage: "person.2.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Label("Mutual follows unlock private chat", systemImage: "bubble.left.and.bubble.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

/// 顶部轮播组件，支持左右滑动浏览上传的所有照片
private struct ListingPhotoCarousel: View {
    let photos: [SnowboardListing.Photo]

    var body: some View {
        TabView {
            ForEach(photos) { photo in
                carouselImage(for: photo)
                    .overlay(alignment: .bottomTrailing) {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.black.opacity(0.0), Color.black.opacity(0.45)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .allowsHitTesting(false)
                    }
            }
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.3), radius: 16, x: 0, y: 8)
    }

    /// 将 Data 解码为 UIImage，失败时回退到渐变占位
    @ViewBuilder
    private func carouselImage(for photo: SnowboardListing.Photo) -> some View {
#if canImport(UIKit)
        if let image = UIImage(data: photo.data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
        } else {
            placeholder
        }
#else
        placeholder
#endif
    }

    private var placeholder: some View {
        LinearGradient(colors: [.blue.opacity(0.6), .purple.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

struct ListingDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ListingDetailView(listing: SampleData.seedListings.first!)
                .environmentObject(
                    MarketplaceViewModel(
                        account: SampleData.defaultAccount,
                        apiClient: APIClient(),
                        autoRefresh: false
                    )
                )

        }
    }
}
