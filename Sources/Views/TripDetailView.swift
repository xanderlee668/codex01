import SwiftUI

struct TripDetailView: View {
    @EnvironmentObject private var marketplace: MarketplaceViewModel
    @State private var localTrip: GroupTrip
    @State private var showingChat = false
    @State private var activeThread: GroupTripThread? = nil

    private let tripID: UUID

    init(trip: GroupTrip) {
        _localTrip = State(initialValue: trip)
        tripID = trip.id
    }

    private var joinState: MarketplaceViewModel.TripJoinState {
        marketplace.tripJoinState(for: localTrip)
    }

    var body: some View {
        List {
            overviewSection
            detailsSection
            joinSection
            pendingRequestsSection
        }
        .listStyle(.insetGrouped)
        .navigationTitle(localTrip.title)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingChat) {
            if let thread = activeThread {
                TripChatView(thread: thread, currentUser: marketplace.currentUser)
                    .environmentObject(marketplace)
            } else {
                Text("Chat unavailable")
                    .font(.headline)
                    .padding()
            }
        }
        .onReceive(marketplace.$groupTrips) { trips in
            guard let updated = trips.first(where: { $0.id == tripID }) else { return }
            localTrip = updated
        }
        .onReceive(marketplace.$tripThreads) { threads in
            guard showingChat, let current = activeThread else { return }
            guard let updated = threads.first(where: { $0.id == current.id }) else { return }
            activeThread = updated
        }
    }

    private var overviewSection: some View {
        Section("Schedule") {
            Label(localTrip.resort, systemImage: "snowflake")
            Label(localTrip.departureLocation, systemImage: "mappin.and.ellipse")
            Label(localTrip.organizer.nickname, systemImage: "person.crop.circle")
            Label {
                Text(localTrip.startDate, format: Date.FormatStyle(date: .complete, time: .shortened))
            } icon: {
                Image(systemName: "calendar")
            }
        }
    }

    private var detailsSection: some View {
        Section("Group details") {
            Label(
                "Confirmed riders: \(localTrip.currentParticipantsCount) / \(localTrip.maximumParticipants)",
                systemImage: "person.3"
            )
            Label("Minimum riders: \(localTrip.minimumParticipants)", systemImage: "person.fill.badge.plus")
            Label {
                Text(localTrip.estimatedCostPerPerson, format: .currency(code: "GBP"))
            } icon: {
                Image(systemName: "sterlingsign.circle")
            }
            Text(localTrip.description)
                .font(.body)
                .foregroundColor(.primary)
                .padding(.top, 4)
        }
    }

    @ViewBuilder
    private var joinSection: some View {
        Section("Participation") {
            switch joinState {
            case .organizer:
                Text("You're hosting this trip.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Button { openChat() } label: {
                    Label("Open group chat", systemImage: "message")
                }
            case .approved:
                Text("You're confirmed. See you on the mountain!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Button { openChat() } label: {
                    Label("Open group chat", systemImage: "message")
                }
            case .pending:
                Text("Your request is awaiting approval from \(localTrip.organizer.nickname).")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            case .notRequested:
                Button { requestToJoin() } label: {
                    Label("Request to join", systemImage: "paperplane")
                }
                .buttonStyle(.borderedProminent)
                Text("The organiser approves each rider before unlocking the chat.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }

    @ViewBuilder
    private var pendingRequestsSection: some View {
        if joinState == .organizer && !localTrip.pendingRequests.isEmpty {
            Section("Pending requests") {
                ForEach(localTrip.pendingRequests) { request in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(request.applicant.nickname)
                                .font(.headline)
                            Text(request.requestedAt, style: .time)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button("Approve") {
                            approve(request: request)
                        }
                        .buttonStyle(.bordered)
                        Button(role: .destructive) {
                            revoke(request: request)
                        } label: {
                            Text("Decline")
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        } else {
            EmptyView()
        }
    }

    private func requestToJoin() {
        _ = marketplace.requestToJoin(trip: localTrip)
        refreshTrip()
    }

    private func approve(request: GroupTrip.JoinRequest) {
        marketplace.approve(request, in: localTrip)
        refreshTrip()
    }

    private func revoke(request: GroupTrip.JoinRequest) {
        marketplace.revoke(request, in: localTrip)
        refreshTrip()
    }

    private func openChat() {
        guard let thread = marketplace.tripThread(for: localTrip) else { return }
        activeThread = thread
        showingChat = true
    }

    private func refreshTrip() {
        if let updated = marketplace.trip(withID: tripID) {
            localTrip = updated
        }
    }
}

struct TripDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            if let trip = SampleData.seedTrips(for: SampleData.defaultAccount).first {
                TripDetailView(trip: trip)
                    .environmentObject(MarketplaceViewModel())
            } else {
                Text("No trip")
            }
        }
    }
}
