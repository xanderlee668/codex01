import SwiftUI

struct ListingListView: View {
    @EnvironmentObject private var marketplace: MarketplaceViewModel
    @EnvironmentObject private var auth: AuthViewModel
    @State private var showingAddSheet = false
    @State private var showingProfile = false

    private var listings: [SnowboardListing] { marketplace.filteredListings }

    var body: some View {
        NavigationView {
            Group {
                if listings.isEmpty {
                    emptyState
                } else {
                    List {
                        filterSection
                        listingsSection
                    }
                    .listStyle(.insetGrouped)
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
            }
            .sheet(isPresented: $showingProfile) {
                ProfileView()
                    .environmentObject(auth)
            }
        }
    }

    private var filterSection: some View {
        Section {
            FilterBarView()
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
        }
    }

    private var listingsSection: some View {
        Section {
            ForEach(listings) { listing in
                NavigationLink(destination: ListingDetailView(listing: listing)) {
                    ListingRowView(listing: listing)
                }
                .swipeActions(edge: .trailing) {
                    Button { toggleFavorite(for: listing) } label: {
                        Label(
                            listing.isFavorite ? "Unfavourite" : "Favourite",
                            systemImage: listing.isFavorite ? "heart.slash" : "heart"
                        )
                    }
                    .tint(.pink)
                }
            }
        }
        .textCase(nil)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "snowflake")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No boards match your filters")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
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
