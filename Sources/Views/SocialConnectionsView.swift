import SwiftUI

struct SocialConnectionsView: View {
    @EnvironmentObject private var socialViewModel: SocialViewModel

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("推荐雪友")) {
                    ForEach(socialViewModel.users) { user in
                        SocialUserRow(
                            user: user,
                            thread: socialViewModel.thread(for: user.id),
                            followAction: {
                                socialViewModel.toggleFollow(for: user)
                            }
                        )
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("雪友关注")
        }
    }
}

private struct SocialUserRow: View {
    let user: UserProfile
    let thread: UserChatThread?
    let followAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: user.avatarSymbol)
                    .font(.title3)
                    .foregroundColor(.accentColor)
                    .frame(width: 48, height: 48)
                    .background(Color.accentColor.opacity(0.15))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(user.displayName)
                            .font(.headline)
                        if user.isFollowingMe {
                            Text("关注了你")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    Text(user.bio)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Label(user.homeResort, systemImage: "mappin")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button(action: followAction) {
                    Text(user.isFollowing ? "已关注" : "关注")
                        .font(.subheadline)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(user.isFollowing ? Color(.systemGray5) : Color.accentColor)
                        .foregroundColor(user.isFollowing ? .primary : .white)
                        .clipShape(Capsule())
                }
            }

            if let thread, user.canChat {
                NavigationLink {
                    UserChatView(thread: thread)
                } label: {
                    HStack {
                        Image(systemName: "message")
                        Text("互相关注，开始聊天")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
            } else {
                HStack(spacing: 6) {
                    Image(systemName: "lock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("互相关注后可发起实时聊天")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct SocialConnectionsView_Previews: PreviewProvider {
    static var previews: some View {
        SocialConnectionsView()
            .environmentObject(SocialViewModel())
    }
}
