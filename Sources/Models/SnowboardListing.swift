import Foundation

struct SnowboardListing: Identifiable, Hashable {
    // MARK: - 内部图片模型
    /// 每条照片都保存一份本地 Data，方便列表、详情页直接解码展示。
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
    /// 用户在发布页挑选的实际图片数据，按照上传顺序存储
    var photos: [Photo]
    var seller: Seller

    struct Seller: Identifiable, Hashable {
        let id: UUID
        var nickname: String
        var rating: Double
        var dealsCount: Int
    }

    /// 统一的英镑货币格式化，列表与详情可复用
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

extension SnowboardListing.Condition {
    init?(apiValue: String) {
        switch apiValue.lowercased() {
        case "new":
            self = .new
        case "like_new":
            self = .likeNew
        case "good":
            self = .good
        case "worn":
            self = .worn
        default:
            return nil
        }
    }

    var apiValue: String {
        switch self {
        case .new:
            return "new"
        case .likeNew:
            return "like_new"
        case .good:
            return "good"
        case .worn:
            return "worn"
        }
    }
}

extension SnowboardListing.TradeOption {
    init?(apiValue: String) {
        switch apiValue.lowercased() {
        case "face_to_face":
            self = .faceToFace
        case "courier":
            self = .courier
        case "hybrid":
            self = .hybrid
        default:
            return nil
        }
    }

    var apiValue: String {
        switch self {
        case .faceToFace:
            return "face_to_face"
        case .courier:
            return "courier"
        case .hybrid:
            return "hybrid"
        }
    }
}
