import SwiftUI

struct ListingListView: View {
    @EnvironmentObject private var marketplace: MarketplaceViewModel
    @EnvironmentObject private var auth: AuthViewModel
    @State private var showingAddSheet = false
    @State private var showingProfile = false

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
                                        ListingRowView(listing: listing) {
                                            toggleFavorite(for: listing)
                                        }
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
            .sheet(isPresented: $showingAddSheet) {
                AddListingView(isPresented: $showingAddSheet)
                    .environmentObject(marketplace)
                    .environmentObject(auth)
                    .preferredColorScheme(.dark)
            }
            .sheet(isPresented: $showingProfile) {
                ProfileView()
                    .environmentObject(auth)
                    .preferredColorScheme(.dark)
            }
            .sheet(isPresented: $showingProfile) {
                ProfileView()
                    .environmentObject(auth)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var filterSection: some View {
        FilterBarView()
            .nightGlassCard()
    }

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

    private var profileToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button { showingProfile = true } label: {
                Image(systemName: "person.crop.circle.fill")
                    .font(.title3)
            }
            .buttonStyle(IconGlassButtonStyle())
        }
    }

    private var profileToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button { showingProfile = true } label: {
                Image(systemName: "person.crop.circle.fill")
                    .font(.title3)
            }
        }
    }

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
        marketplace.toggleFavorite(for: listing)
    }
}

struct ListingListView_Previews: PreviewProvider {
    static var previews: some View {
        ListingListView()
            .environmentObject(MarketplaceViewModel())
            .environmentObject(AuthViewModel())
    }
}
