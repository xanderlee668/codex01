import SwiftUI

struct ListingRowView: View {
    let listing: SnowboardListing
    var onToggleFavorite: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .top, spacing: 18) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.accentColor.opacity(0.55), Color.blue.opacity(0.35)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 72, height: 72)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                    )
                    .shadow(color: Color.accentColor.opacity(0.5), radius: 18, x: 0, y: 10)

                Image(systemName: "snowboard")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.4), radius: 8, x: 0, y: 4)
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    Text(listing.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    if let onToggleFavorite {
                        Button(action: onToggleFavorite) {
                            Image(systemName: listing.isFavorite ? "heart.fill" : "heart")
                                .font(.title3)
                                .foregroundColor(listing.isFavorite ? .pink : .white)
                                .padding(10)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.1))
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white.opacity(0.25), lineWidth: 1)
                                        )
                                )
                        }
                        .buttonStyle(.plain)
                        .shadow(color: (listing.isFavorite ? Color.pink : Color.black).opacity(0.35), radius: 10, x: 0, y: 4)
                    } else if listing.isFavorite {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.pink)
                            .shadow(color: Color.pink.opacity(0.4), radius: 8, x: 0, y: 4)
                    }
                }

                Text(listing.description)
                    .lineLimit(2)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.75))

                HStack {
                    Label(listing.location, systemImage: "mappin.and.ellipse")
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text(listing.formattedPrice)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .font(.caption)
            }
        }
        .nightGlassCard()
    }
}

struct ListingRowView_Previews: PreviewProvider {
    static var previews: some View {
        ListingRowView(listing: SampleData.seedListings.first!)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
