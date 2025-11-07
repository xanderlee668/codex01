import SwiftUI

struct ListingDetailView: View {
    @EnvironmentObject private var marketplace: MarketplaceViewModel
    @State private var localListing: SnowboardListing
    @State private var showingContactAlert = false
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

                SellerCardView(seller: localListing.seller)
            }
            .padding()
        }
        .navigationTitle("详情")
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button {
                    showingContactAlert = true
                } label: {
                    Label("联系卖家", systemImage: "phone")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .alert("联系卖家", isPresented: $showingContactAlert) {
            Button("好的", role: .cancel) { showingContactAlert = false }
        } message: {
            Text("请通过平台提供的联系方式或电话与卖家沟通细节。")
        }
        .onReceive(marketplace.$listings) { listings in
            guard let updated = listings.first(where: { $0.id == listingID }) else { return }
            localListing = updated
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
    let seller: SnowboardListing.Seller

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
            }

            Text("用心挑选器材，只为帮你找到最合适的雪板。支持面交验货，欢迎放心咨询！")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct ListingDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ListingDetailView(listing: SampleData.listings.first!)
                .environmentObject(MarketplaceViewModel())
        }
    }
}
