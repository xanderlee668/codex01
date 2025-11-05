import Foundation

struct UserProfile: Identifiable, Hashable {
    let id: UUID
    var displayName: String
    var bio: String
    var homeResort: String
    var isFollowing: Bool
    var isFollowingMe: Bool
    var avatarSymbol: String

    var canChat: Bool {
        isFollowing && isFollowingMe
    }
}

struct UserChatMessage: Identifiable, Hashable {
    let id: UUID
    var isCurrentUser: Bool
    var text: String
    var timestamp: Date
}

struct UserChatThread: Identifiable, Hashable {
    let id: UUID
    var user: UserProfile
    var messages: [UserChatMessage]
}

struct GroupRide: Identifiable, Hashable {
    let id: UUID
    var organizer: UserProfile
    var resortName: String
    var resortLocation: String
    var departureDate: Date
    var durationDays: Int
    var participantLimit: Int
    var estimatedCostPerPerson: Double

    var formattedDateRange: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日"
        let start = formatter.string(from: departureDate)
        let endDate = Calendar.current.date(byAdding: .day, value: durationDays - 1, to: departureDate) ?? departureDate
        let end = formatter.string(from: endDate)
        if start == end {
            return "出发：\(start) • \(durationDays) 天"
        } else {
            return "行程：\(start) - \(end) • \(durationDays) 天"
        }
    }

    var formattedCost: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "¥"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: estimatedCostPerPerson)) ?? "¥0"
    }
}
