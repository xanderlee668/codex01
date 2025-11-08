import SwiftUI

struct TripChatView: View {
    @EnvironmentObject private var marketplace: MarketplaceViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var draft: String = ""
    @State private var localThread: GroupTripThread

    private let threadID: UUID
    private let tripID: UUID
    private let currentUser: SnowboardListing.Seller

    init(thread: GroupTripThread, currentUser: SnowboardListing.Seller) {
        _localThread = State(initialValue: thread)
        threadID = thread.id
        tripID = thread.tripID
        self.currentUser = currentUser
    }

    private var tripTitle: String {
        marketplace.trip(withID: tripID)?.title ?? "Group Chat"
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                List {
                    ForEach(localThread.messages) { message in
                        TripMessageBubble(message: message, isCurrentUser: message.senderID == currentUser.id)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                    }
                }
                .listStyle(.plain)

                HStack(spacing: 12) {
                    TextField("Share an update...", text: $draft)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                    Button(action: send) {
                        Image(systemName: "paperplane.fill")
                    }
                    .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
                .background(Color(.systemGray6))
            }
            .navigationTitle(tripTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .onReceive(marketplace.$tripThreads) { threads in
            guard let updated = threads.first(where: { $0.id == threadID }) else { return }
            localThread = updated
        }
    }

    private func send() {
        let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if let message = marketplace.sendTripMessage(trimmed, in: localThread, sender: currentUser) {
            localThread.messages.append(message)
        }
        draft = ""
    }
}

private struct TripMessageBubble: View {
    let message: GroupTripMessage
    let isCurrentUser: Bool

    var body: some View {
        HStack {
            if isCurrentUser { Spacer(minLength: 0) }

            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 6) {
                Text(message.senderName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(message.text)
                    .padding(12)
                    .background(isCurrentUser ? Color.accentColor.opacity(0.2) : Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            if !isCurrentUser { Spacer(minLength: 0) }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

struct TripChatView_Previews: PreviewProvider {
    static var previews: some View {
        let trips = SampleData.seedTrips(for: SampleData.defaultAccount)
        if let thread = SampleData.seedTripThreads(for: trips, account: SampleData.defaultAccount).first {
            return TripChatView(thread: thread, currentUser: SampleData.defaultAccount.seller)
                .environmentObject(MarketplaceViewModel())
        } else {
            return EmptyView()
        }
    }
}
