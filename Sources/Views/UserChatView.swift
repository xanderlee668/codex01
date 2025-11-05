import SwiftUI

struct UserChatView: View {
    @EnvironmentObject private var socialViewModel: SocialViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var draft: String = ""
    @State private var localThread: UserChatThread
    private let threadID: UUID

    init(thread: UserChatThread) {
        _localThread = State(initialValue: thread)
        threadID = thread.id
    }

    var body: some View {
        VStack(spacing: 0) {
            List {
                ForEach(localThread.messages) { message in
                    UserMessageBubble(message: message)
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
        .navigationTitle(localThread.user.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("关闭") { dismiss() }
            }
        }
        .onReceive(socialViewModel.$threads) { threads in
            guard let updated = threads.first(where: { $0.id == threadID }) else { return }
            localThread = updated
        }
    }

    private func send() {
        let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if let message = socialViewModel.sendMessage(trimmed, in: localThread) {
            localThread.messages.append(message)
        }
        draft = ""
    }
}

private struct UserMessageBubble: View {
    let message: UserChatMessage

    var body: some View {
        HStack {
            if message.isCurrentUser { Spacer() }

            VStack(alignment: message.isCurrentUser ? .trailing : .leading, spacing: 6) {
                Text(message.isCurrentUser ? "我" : "雪友")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(message.text)
                    .padding(12)
                    .background(message.isCurrentUser ? Color.accentColor.opacity(0.2) : Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            if !message.isCurrentUser { Spacer() }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

struct UserChatView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UserChatView(thread: SampleData.communityThreads.first!)
                .environmentObject(SocialViewModel())
        }
    }
}
