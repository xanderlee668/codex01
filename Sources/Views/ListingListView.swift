import SwiftUI

struct ListingListView: View {
    @EnvironmentObject private var marketplace: MarketplaceViewModel
    @EnvironmentObject private var auth: AuthViewModel
    @State private var activeSheet: ActiveSheet?

    private enum ActiveSheet: Identifiable {
        case addListing
        case thread(MessageThread)

        var id: String {
            switch self {
            case .addListing:
                return "addListing"
            case .thread(let thread):
                return thread.id.uuidString
            }
        }
    }

    private var currentUserName: String {
        auth.currentUser?.displayName ?? "未登录"
    }

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
                                ListingRowView(listing: listing) {
                                    let thread = marketplace.thread(for: listing)
                                    activeSheet = .thread(thread)
                                }
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
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        if let user = auth.currentUser {
                            Label("交易完成：\(user.dealsCount)", systemImage: "handbag")
                            Label(String(format: "好评率：%.1f", user.rating), systemImage: "star")
                        }
                        Button(role: .destructive) {
                            auth.logout()
                        } label: {
                            Label("退出登录", systemImage: "rectangle.portrait.and.arrow.forward")
                        }
                    } label: {
                        Label(currentUserName, systemImage: "person.crop.circle")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        activeSheet = .addListing
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .addListing:
                    AddListingView(
                        isPresented: Binding(
                            get: {
                                if case .addListing = activeSheet { return true }
                                return false
                            },
                            set: { newValue in
                                if !newValue {
                                    activeSheet = nil
                                }
                            }
                        )
                    )
                    .environmentObject(marketplace)
                    .environmentObject(auth)
                case .thread(let thread):
                    NavigationStack {
                        MessageThreadView(thread: thread, showsCloseButton: true)
                    }
                    .environmentObject(marketplace)
                    MessageThreadView(thread: thread)
                        .environmentObject(marketplace)
                }
            }
        }
    }
}

struct ListingListView_Previews: PreviewProvider {
    static var previews: some View {
        ListingListView()
            .environmentObject(MarketplaceViewModel())
            .environmentObject(AuthViewModel(currentUser: SampleData.users.first))
    }
}
