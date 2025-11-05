import Foundation

final class GroupRideViewModel: ObservableObject {
    @Published var rides: [GroupRide]
    let currentUser: UserProfile

    init(rides: [GroupRide] = SampleData.demoGroupRides,
         currentUser: UserProfile = .init(
             id: UUID(),
             displayName: "我",
             bio: "热爱雪板的旅途规划师",
             homeResort: "北京·怀北",
             isFollowing: true,
             isFollowingMe: true,
             avatarSymbol: "person.fill"
         )) {
        self.rides = rides
        self.currentUser = currentUser
    }

    func addRide(resortName: String,
                 resortLocation: String,
                 departureDate: Date,
                 durationDays: Int,
                 participantLimit: Int,
                 estimatedCostPerPerson: Double) {
        let newRide = GroupRide(
            id: UUID(),
            organizer: currentUser,
            resortName: resortName,
            resortLocation: resortLocation,
            departureDate: departureDate,
            durationDays: durationDays,
            participantLimit: participantLimit,
            estimatedCostPerPerson: estimatedCostPerPerson
        )
        rides.insert(newRide, at: 0)
    }
}
