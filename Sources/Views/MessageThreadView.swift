import SwiftUI

struct MessageThreadView: View {
    @EnvironmentObject private var marketplace: MarketplaceViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var draft: String = ""
    @State private var localThread: MessageThread
    private let threadID: UUID

    init(thread: MessageThread) {
        _localThread = State(initialValue: thread)
        threadID = thread.id
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                List {
                    ForEach(localThread.messages) { message in
                        MessageBubble(message: message)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                    }
                }
                .listStyle(.plain)

                HStack(spacing: 12) {
                    TextField("Type a message...", text: $draft)
                        .textFieldStyle(.roundedBorder)
                        .disableAutocorrection(true)
                    Button(action: send) {
                        Image(systemName: "paperplane.fill")
                    }
                    .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
                .background(Color(.systemGray6))
            }
            .navigationTitle(localThread.listing.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .onReceive(marketplace.$threads) { threads in
            guard let updated = threads.first(where: { $0.id == threadID }) else { return }
            localThread = updated
        }
    }

    private func send() {
        let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if let message = marketplace.sendMessage(trimmed, in: localThread) {
            localThread.messages.append(message)
        }
        draft = ""
    }
}

private struct MessageBubble: View {
    let message: Message

    var body: some View {
        HStack {
            if message.sender == .buyer { Spacer(minLength: 0) }

            VStack(alignment: message.sender == .buyer ? .trailing : .leading, spacing: 6) {
                Text(message.sender.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(message.text)
                    .padding(12)
                    .background(message.sender == .buyer ? Color.accentColor.opacity(0.2) : Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            if message.sender == .seller { Spacer(minLength: 0) }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

struct MessageThreadView_Previews: PreviewProvider {
    static var previews: some View {
        if let thread = SampleData.seedThreads(for: SampleData.seedListings, account: SampleData.defaultAccount).first {
            MessageThreadView(thread: thread)
                .environmentObject(
                    MarketplaceViewModel(account: SampleData.defaultAccount, apiClient: APIClient())
                )
        } else if let listing = SampleData.seedListings.first {
            MessageThreadView(thread: MessageThread(id: UUID(), listing: listing, messages: []))
                .environmentObject(
                    MarketplaceViewModel(account: SampleData.defaultAccount, apiClient: APIClient())
                )
        } else {
            EmptyView()
        }
    }
}

