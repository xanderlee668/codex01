import SwiftUI

struct ListingListView: View {
    @EnvironmentObject private var marketplace: MarketplaceViewModel
    @EnvironmentObject private var auth: AuthViewModel
    @State private var showingAddSheet = false
    @State private var showingProfile = false

    /// 直接复用 ViewModel 的过滤结果，保证筛选逻辑单一来源
    private var listings: [SnowboardListing] { marketplace.filteredListings }

    var body: some View {
        NavigationView {
            ZStack {
                NightGradientBackground()

                Group {
                    if listings.isEmpty {
                        emptyState
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 22) {
                                filterSection

                                ForEach(listings) { listing in
                                    NavigationLink(destination: ListingDetailView(listing: listing)) {
                                        ListingRowView(
                                            listing: listing,
                                            onToggleFavorite: { toggleFavorite(for: listing) },
                                            isFavoriteUpdating: marketplace.favoriteUpdatesInFlight.contains(listing.id)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                    .contextMenu {
                                        Button(role: nil) {
                                            toggleFavorite(for: listing)
                                        } label: {
                                            Label(
                                                listing.isFavorite ? "Unfavourite" : "Favourite",
                                                systemImage: listing.isFavorite ? "heart.slash" : "heart"
                                            )
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 32)
                            .padding(.horizontal, 20)
                        }
                    }
                }
            }
            .navigationTitle("Marketplace")
            .toolbar {
                profileToolbarItem
                addListingToolbarItem
            }
            // 发布入口支持 iOS 16+ 图片上传，旧系统弹出提示页
            .sheet(isPresented: $showingAddSheet) {
                if #available(iOS 16.0, *) {
                    AddListingView(isPresented: $showingAddSheet)
                        .environmentObject(marketplace)
                        .environmentObject(auth)
                        .preferredColorScheme(.dark)
                } else {
                    LegacyAddListingPlaceholder(isPresented: $showingAddSheet)
                        .preferredColorScheme(.dark)
                }
            }
            // 左上角头像入口，打开个人信息页
            .sheet(isPresented: $showingProfile) {
                ProfileView()
                    .environmentObject(auth)
                    .preferredColorScheme(.dark)
            }
        }
        .preferredColorScheme(.dark)
    }

    /// 顶部过滤器模块，抽成子视图方便复用
    private var filterSection: some View {
        FilterBarView()
            .nightGlassCard()
    }

    /// 当筛选无结果时的提示卡片
    private var emptyState: some View {
        VStack(spacing: 18) {
            Image(systemName: "snowflake")
                .font(.system(size: 56))
                .foregroundColor(.white.opacity(0.7))
            Text("No boards match your filters")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
            Text("Adjust your filters or clear them to see more listings.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .nightGlassCard(padding: 28)
        .padding(.horizontal, 32)
    }

    /// 左上角 Profile 入口按钮
    private var profileToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button { showingProfile = true } label: {
                Image(systemName: "person.crop.circle.fill")
                    .font(.title3)
            }
            .buttonStyle(IconGlassButtonStyle())
        }
    }

    /// 右上角发布入口按钮
    private var addListingToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button { showingAddSheet = true } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
            }
            .buttonStyle(IconGlassButtonStyle())
        }
    }

    private func toggleFavorite(for listing: SnowboardListing) {
        Task { await marketplace.toggleFavorite(for: listing) }
    }
}

private struct LegacyAddListingPlaceholder: View {
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            VStack(spacing: 18) {
                Image(systemName: "photo")
                    .font(.system(size: 48))
                    .foregroundColor(.white.opacity(0.7))
                Text("Update required")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("Photo uploads require iOS 16 or later. Update your device to share gear snapshots.")
                    .multilineTextAlignment(.center)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal)
                Button("Close") {
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
                .tint(.accentColor)
            }
            .padding(32)
            .background(NightGradientBackground())
            .navigationTitle("Add listing")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ListingListView_Previews: PreviewProvider {
    static var previews: some View {
        ListingListView()
            .environmentObject(MarketplaceViewModel.preview())
            .environmentObject(AuthViewModel.previewAuthenticated())
    }
}

