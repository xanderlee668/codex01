import SwiftUI

struct TripListView: View {
    @EnvironmentObject private var marketplace: MarketplaceViewModel
    @EnvironmentObject private var auth: AuthViewModel
    @State private var showingCreateSheet = false
    @State private var showingProfile = false

    var body: some View {
        NavigationView {
            ZStack {
                NightGradientBackground()

                if marketplace.sortedTrips.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: 22) {
                            ForEach(marketplace.sortedTrips) { trip in
                                NavigationLink(destination: TripDetailView(trip: trip)) {
                                    TripRow(trip: trip, joinState: marketplace.tripJoinState(for: trip))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 32)
                        .padding(.horizontal, 20)
                    }
                }
            }
            .navigationTitle("Group Trips")
            .toolbar {
                profileToolbarItem
                addTripToolbarItem
            }
            .sheet(isPresented: $showingCreateSheet) {
                CreateTripView(isPresented: $showingCreateSheet)
                    .environmentObject(marketplace)
                    .preferredColorScheme(.dark)
            }
            .sheet(isPresented: $showingProfile) {
                ProfileView()
                    .environmentObject(auth)
            }
        }
    }

    private var profileToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button { showingProfile = true } label: {
                Image(systemName: "person.crop.circle.fill")
                    .font(.title3)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var addTripToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button { showingCreateSheet = true } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
            }
            .buttonStyle(IconGlassButtonStyle())
        }
    }

    private var emptyState: some View {
        VStack(spacing: 18) {
            Image(systemName: "figure.snowboarding")
                .font(.system(size: 56))
                .foregroundColor(.white.opacity(0.75))
            Text("No group trips yet")
                .font(.headline)
                .foregroundColor(.white.opacity(0.85))
            Text("Start a trip to find riding buddies across Europe.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.65))
        }
        .nightGlassCard(padding: 28)
        .padding(.horizontal, 32)
    }
}

private struct TripRow: View {
    let trip: GroupTrip
    let joinState: MarketplaceViewModel.TripJoinState

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(trip.title)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text(trip.startDate, formatter: Self.dateFormatter)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }

            VStack(alignment: .leading, spacing: 6) {
                Label(trip.resort, systemImage: "snowflake")
                Label("Departs from \(trip.departureLocation)", systemImage: "mappin.and.ellipse")
                Label(
                    "Confirmed riders: \(trip.currentParticipantsCount) / \(trip.maximumParticipants)",
                    systemImage: "person.3"
                )
                Label {
                    Text(trip.estimatedCostPerPerson, format: .currency(code: "GBP"))
                } icon: {
                    Image(systemName: "sterlingsign.circle")
                }
            }
            .font(.subheadline)
            .foregroundColor(.white.opacity(0.7))

            joinBadge
        }
        .nightGlassCard()
    }

    @ViewBuilder
    private var joinBadge: some View {
        switch joinState {
        case .organizer:
            badgeView(text: "You're organising", color: .blue)
        case .approved:
            badgeView(text: "Approved to ride", color: .green)
        case .pending:
            badgeView(text: "Request pending", color: .orange)
        case .notRequested:
            EmptyView()
        }
    }

    private func badgeView(text: String, color: Color) -> some View {
        Text(text)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule(style: .continuous)
                    .fill(color.opacity(0.18))
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(color.opacity(0.4), lineWidth: 1)
                    )
            )
    }
}

struct TripListView_Previews: PreviewProvider {
    static var previews: some View {
        TripListView()
            .environmentObject(MarketplaceViewModel())
            .environmentObject(AuthViewModel())
    }
}
