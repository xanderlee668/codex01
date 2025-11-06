import SwiftUI

struct MessageThreadView: View {
    @EnvironmentObject private var marketplace: MarketplaceViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var draft: String = ""
    @State private var localThread: MessageThread
    private let thread: MessageThread
    private let showsCloseButton: Bool

    init(thread: MessageThread, showsCloseButton: Bool = false) {
        self.thread = thread
        self.showsCloseButton = showsCloseButton
        _localThread = State(initialValue: thread)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                List {
                    if localThread.messages.isEmpty {
                        EmptyConversationRow(sellerName: localThread.seller.nickname)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                            .id(message.id)
                    }
                }
                .listStyle(.plain)
                .onAppear {
                    scrollToBottom(proxy, animated: false)
                }
                .onChange(of: localThread.messages) { _ in
                    scrollToBottom(proxy, animated: true)
                }
            }
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
                    .submitLabel(.send)
                    .onSubmit(send)
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
            if showsCloseButton {
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

    private func scrollToBottom(_ proxy: ScrollViewProxy, animated: Bool) {
        guard let last = localThread.messages.last else { return }
        DispatchQueue.main.async {
            if animated {
                withAnimation {
                    proxy.scrollTo(last.id, anchor: .bottom)
                }
            } else {
                proxy.scrollTo(last.id, anchor: .bottom)
            }
        }
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

private struct EmptyConversationRow: View {
    let sellerName: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "paperplane")
                .font(.system(size: 44))
                .foregroundColor(.accentColor)
            Text("和 \(sellerName) 打个招呼吧！")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("发送第一条消息开启沟通")
                .font(.caption)
                .foregroundColor(Color(.tertiaryLabel))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
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
