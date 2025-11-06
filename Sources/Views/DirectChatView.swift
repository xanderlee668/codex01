import SwiftUI

struct DirectChatView: View {
    @EnvironmentObject private var auth: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var draft: String = ""
    @State private var localThread: DirectMessageThread

    private let partner: User

    init(partner: User, thread: DirectMessageThread) {
        self.partner = partner
        _localThread = State(initialValue: thread)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if localThread.messages.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 48))
                            .foregroundColor(.accentColor)
                        Text("互相关注后，你们可以在这里安心沟通装备细节。")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(localThread.messages) { message in
                            DirectMessageBubble(
                                message: message,
                                isCurrentUser: message.senderID == auth.currentUser?.id,
                                partnerName: partner.displayName
                            )
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                        }
                    }
                    .listStyle(.plain)
                }

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
            .navigationTitle(partner.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { dismiss() }
                }
            }
        }
        .onReceive(auth.$directThreads) { threads in
            guard let updated = threads.first(where: { $0.id == localThread.id }) else { return }
            localThread = updated
        }
    }

    private func send() {
        let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard let message = auth.sendDirectMessage(trimmed, in: localThread) else { return }
        localThread.messages.append(message)
        draft = ""
    }
}

private struct DirectMessageBubble: View {
    let message: DirectMessage
    let isCurrentUser: Bool
    let partnerName: String

    var body: some View {
        HStack {
            if isCurrentUser { Spacer() }

            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 6) {
                Text(isCurrentUser ? "我" : partnerName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(message.text)
                    .padding(12)
                    .background(isCurrentUser ? Color.accentColor.opacity(0.2) : Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            if !isCurrentUser { Spacer() }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

struct DirectChatView_Previews: PreviewProvider {
    static var previews: some View {
        DirectChatView(
            partner: SampleData.users[1],
            thread: SampleData.directThreads.first!
        )
        .environmentObject(AuthViewModel(currentUser: SampleData.users.first))
    }
}
