import SwiftUI

struct ListingListView: View {
    @EnvironmentObject private var marketplace: MarketplaceViewModel
    @State private var showingAddSheet = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                FilterBarView()
                    .padding(.horizontal)
                    .padding(.top)

                if marketplace.filteredListings.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "snowflake")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("暂时没有符合条件的雪板")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    List {
                        ForEach(marketplace.filteredListings) { listing in
                            NavigationLink(destination: ListingDetailView(listing: listing)) {
                                ListingRowView(listing: listing)
                            }
                            .swipeActions(edge: .trailing) {
                                Button {
                                    marketplace.toggleFavorite(for: listing)
                                } label: {
                                    Label(
                                        listing.isFavorite ? "取消收藏" : "收藏",
                                        systemImage: listing.isFavorite ? "heart.slash" : "heart"
                                    )
                                }
                                .tint(.pink)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("雪板集市")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddListingView(isPresented: $showingAddSheet)
                    .environmentObject(marketplace)
            }
        }
    }
}

struct ListingListView_Previews: PreviewProvider {
    static var previews: some View {
        ListingListView()
            .environmentObject(MarketplaceViewModel())
    }
}
