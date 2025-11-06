import SwiftUI

struct ListingRowView: View {
    let listing: SnowboardListing
    var onMessageTapped: (() -> Void)? = nil
    var onSellerTapped: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.systemBlue).opacity(0.15))
                    .frame(width: 72, height: 72)
                Image(systemName: "snowboard")
                    .font(.system(size: 30))
                    .foregroundColor(.blue)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(listing.title)
                        .font(.headline)
                    Spacer()
                    if listing.isFavorite {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.pink)
                    }
                }

                Text(listing.description)
                    .lineLimit(2)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack {
                    Label(listing.location, systemImage: "mappin.and.ellipse")
                    Spacer()
                    Text(listing.formattedPrice)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                .font(.caption)

                SellerBadgeView(seller: listing.seller, onMessageTapped: onMessageTapped)
                SellerBadgeView(seller: listing.seller, onTap: onSellerTapped)
            }
        }
        .padding(.vertical, 8)
    }
}

private struct SellerBadgeView: View {
    let seller: SnowboardListing.Seller
    let onMessageTapped: (() -> Void)?
    let onTap: (() -> Void)?

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            avatar

            VStack(alignment: .leading, spacing: 4) {
                Text(seller.nickname)
                    .font(.subheadline.weight(.semibold))
                nameButton

                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", seller.rating))
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "person.2.fill")
                        Text(String(format: "成交 %d 笔", seller.dealsCount))
                    }
                }
                .font(.caption2)
                .foregroundColor(.secondary)
            }

            Spacer()

            if let onMessageTapped {
                ChatActionButton(style: .filled, action: onMessageTapped)
                    .accessibilityLabel("向\(seller.nickname)发送消息")
            if onTap != nil {
                Button(action: { onTap?() }) {
                    Label("私聊", systemImage: "bubble.right")
                        .font(.caption)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                }
                .buttonStyle(.borderedProminent)
                .tint(.accentColor)
            }
        }
        .padding(.top, 10)
    }

    private var avatar: some View {
        Circle()
    @ViewBuilder
    private var avatar: some View {
        let avatarView = Circle()
            .fill(Color.accentColor.opacity(0.15))
            .frame(width: 40, height: 40)
            .overlay(
                Image(systemName: "person.fill")
                    .foregroundColor(.accentColor)
            )

        if let onTap {
            Button(action: onTap) {
                avatarView
            }
            .buttonStyle(.plain)
            .accessibilityLabel("联系\(seller.nickname)")
        } else {
            avatarView
        }
    }

    @ViewBuilder
    private var nameButton: some View {
        if let onTap {
            Button(action: onTap) {
                Text(seller.nickname)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.accentColor)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("向\(seller.nickname)发送消息")
        } else {
            Text(seller.nickname)
                .font(.subheadline.weight(.semibold))
        }
    }
}

struct ListingRowView_Previews: PreviewProvider {
    static var previews: some View {
        ListingRowView(listing: SampleData.listings.first!, onMessageTapped: {})
        ListingRowView(listing: SampleData.listings.first!, onSellerTapped: {})
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
