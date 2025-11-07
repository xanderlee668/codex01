import SwiftUI

struct ListingRowView: View {
    let listing: SnowboardListing

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
            }
        }
        .padding(.vertical, 8)
    }
}

struct ListingRowView_Previews: PreviewProvider {
    static var previews: some View {
        ListingRowView(listing: SampleData.seedListings.first!)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
