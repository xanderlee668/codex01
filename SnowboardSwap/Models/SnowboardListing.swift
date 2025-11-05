import Foundation

struct SnowboardListing: Identifiable, Hashable {
    enum Condition: String, CaseIterable, Identifiable {
        case new = "全新"
        case likeNew = "九成新"
        case good = "良好"
        case worn = "有使用痕迹"

        var id: String { rawValue }
    }

    enum TradeOption: String, CaseIterable, Identifiable {
        case faceToFace = "当面交易"
        case courier = "快递寄送"
        case hybrid = "面交或快递"

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
        formatter.currencySymbol = "¥"
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    var formattedPrice: String {
        SnowboardListing.formatter.string(from: NSNumber(value: price)) ?? "¥0"
    }
}
