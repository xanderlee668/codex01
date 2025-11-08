import SwiftUI

struct TripListView: View {
    @EnvironmentObject private var marketplace: MarketplaceViewModel
    @EnvironmentObject private var auth: AuthViewModel
    @State private var showingCreateSheet = false
    @State private var showingProfile = false

    var body: some View {
        NavigationView {
            Group {
                if marketplace.sortedTrips.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(marketplace.sortedTrips) { trip in
                            NavigationLink(destination: TripDetailView(trip: trip)) {
                                TripRow(trip: trip, joinState: marketplace.tripJoinState(for: trip))
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
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
    }

    private var addTripToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button { showingCreateSheet = true } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.snowboarding")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No group trips yet")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Start a trip to find riding buddies across Europe.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
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
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(trip.title)
                    .font(.headline)
                Spacer()
                Text(trip.startDate, formatter: Self.dateFormatter)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Label(trip.resort, systemImage: "snowflake")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Label("Departs from \(trip.departureLocation)", systemImage: "mappin.and.ellipse")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Label(
                    "Confirmed riders: \(trip.currentParticipantsCount) / \(trip.maximumParticipants)",
                    systemImage: "person.3"
                )
                .font(.subheadline)
                .foregroundColor(.secondary)
                Label {
                    Text(trip.estimatedCostPerPerson, format: .currency(code: "GBP"))
                } icon: {
                    Image(systemName: "sterlingsign.circle")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }

            joinBadge
        }
        .padding(.vertical, 8)
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
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }
}

struct TripListView_Previews: PreviewProvider {
    static var previews: some View {
        TripListView()
            .environmentObject(MarketplaceViewModel())
            .environmentObject(AuthViewModel())
    }
}
