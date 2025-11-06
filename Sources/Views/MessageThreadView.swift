import SwiftUI

struct MessageThreadView: View {
    @EnvironmentObject private var marketplace: MarketplaceViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var draft: String = ""
    @State private var localThread: MessageThread
    private let thread: MessageThread

    init(thread: MessageThread) {
        self.thread = thread
        _localThread = State(initialValue: thread)
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

                HStack {
                    TextField("输入消息...", text: $draft)
                        .textFieldStyle(.roundedBorder)
                    Button {
                        send()
                    } label: {
                        Image(systemName: "paperplane.fill")
                    }
                    .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
                .background(Color(.systemGray6))
            }
            .navigationTitle(localThread.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { dismiss() }
                }
            }
        }
        .onReceive(marketplace.$threads) { threads in
            guard let updated = threads.first(where: { $0.id == thread.id }) else { return }
            localThread = updated
        }
    }

    private func send() {
        let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        marketplace.sendMessage(trimmed, in: thread)
        localThread.messages.append(
            Message(id: UUID(), sender: .buyer, text: trimmed, timestamp: Date())
        )
        draft = ""
    }
}

private struct MessageBubble: View {
    let message: Message

    var body: some View {
        HStack {
            if message.sender == .buyer { Spacer() }

            VStack(alignment: message.sender == .buyer ? .trailing : .leading, spacing: 6) {
                Text(message.sender.name)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(message.text)
                    .padding(12)
                    .background(message.sender == .buyer ? Color.accentColor.opacity(0.2) : Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            if message.sender == .seller { Spacer() }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

struct MessageThreadView_Previews: PreviewProvider {
    static var previews: some View {
        MessageThreadView(
            thread: .init(
                id: UUID(),
                seller: SampleData.listings.first!.seller,
                listing: SampleData.listings.first!,
                messages: SampleData.demoMessages
            )
        )
        .environmentObject(MarketplaceViewModel())
    }
}
