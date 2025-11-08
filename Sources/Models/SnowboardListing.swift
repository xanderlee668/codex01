import Foundation

struct SnowboardListing: Identifiable, Hashable {
    struct Photo: Identifiable, Hashable {
        let id: UUID
        var data: Data

        init(id: UUID = UUID(), data: Data) {
            self.id = id
            self.data = data
        }
    }

    enum Condition: String, CaseIterable, Identifiable {
        case new = "Brand New"
        case likeNew = "Like New"
        case good = "Good"
        case worn = "Well Used"

        var id: String { rawValue }
    }

    enum TradeOption: String, CaseIterable, Identifiable {
        case faceToFace = "Face to face"
        case courier = "Courier"
        case hybrid = "Face to face or courier"

        var id: String { rawValue }
    }

    let id: UUID
    var title: String
    var description: String
    var condition: Condition
    var price: Double
    var location: String
    var tradeOption: TradeOption
    var isFavorite: Bool
    var imageName: String
    var photos: [Photo]
    var seller: Seller

    struct Seller: Identifiable, Hashable {
        let id: UUID
        var nickname: String
        var rating: Double
        var dealsCount: Int
    }

    static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_GB")
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    var formattedPrice: String {
        SnowboardListing.formatter.string(from: NSNumber(value: price)) ?? "£0"
    }
}
