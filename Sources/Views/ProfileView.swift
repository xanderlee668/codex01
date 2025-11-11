import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var auth: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var displayName: String = ""
    @State private var email: String = ""
    @State private var location: String = ""
    @State private var bio: String = ""

    @State private var infoMessage: Feedback? = nil
    @State private var passwordMessage: Feedback? = nil

    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""

    private struct Feedback: Identifiable {
        enum Kind {
            case success
            case error
        }

        let id = UUID()
        let message: String
        let kind: Kind
    }

    var body: some View {
        NavigationStack {
            ZStack {
                NightGradientBackground()

                ScrollView {
                    VStack(spacing: 26) {
                        if auth.isAuthenticated {
                            // 已登录状态：展示资料、密码与会话操作
                            personalInformationCard
                            changePasswordCard
                            sessionActionsCard
                        } else {
                            // 未登录状态给出提示
                            loggedOutCard
                        }
                    }
                    .padding(.vertical, 40)
                    .padding(.horizontal, 24)
                }
            }
            .navigationTitle("Profile")
            .onAppear(perform: populateFields)
            .onChange(of: auth.currentAccount?.id) { _ in
                populateFields()
            }
            .onChange(of: auth.isAuthenticated) { _ in
                populateFields()
            }
        }
        .preferredColorScheme(.dark)
    }

    private var personalInformationCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Personal Information")
                .font(.title3.weight(.semibold))
                .foregroundColor(.white)

            VStack(spacing: 16) {
                glassField(title: "Display Name", text: $displayName)

                glassField(title: "Email", text: $email, keyboard: .emailAddress, autocapitalization: .never)

                glassField(title: "Location", text: $location)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Bio")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.75))

                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.white.opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
                            )

                        TextEditor(text: $bio)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .frame(minHeight: 140)
                            .padding(10)
                            .foregroundColor(.white)
                    }
                }
            }

            if let message = infoMessage {
                Text(message.message)
                    .font(.footnote)
                    .foregroundColor(message.kind == .error ? Color.red.opacity(0.9) : Color.green.opacity(0.9))
            }

            Button("Save Changes", action: saveProfile)
                .buttonStyle(PrimaryGlassButtonStyle())
                .opacity(displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1)
                .disabled(displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .nightGlassCard()
    }

    private var changePasswordCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Change Password")
                .font(.title3.weight(.semibold))
                .foregroundColor(.white)

            VStack(spacing: 16) {
                glassSecureField(title: "Current Password", text: $currentPassword)
                glassSecureField(title: "New Password", text: $newPassword)
                glassSecureField(title: "Confirm New Password", text: $confirmPassword)
            }

            if let message = passwordMessage {
                Text(message.message)
                    .font(.footnote)
                    .foregroundColor(message.kind == .error ? Color.red.opacity(0.9) : Color.green.opacity(0.9))
            }

            Button("Update Password", action: updatePassword)
                .buttonStyle(PrimaryGlassButtonStyle())
                .opacity((currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) ? 0.6 : 1)
                .disabled(currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty)
        }
        .nightGlassCard()
    }

    private var sessionActionsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Session")
                .font(.title3.weight(.semibold))
                .foregroundColor(.white)

            Text("Signed in as \(displayName.isEmpty ? (auth.currentAccount?.email ?? "") : displayName)")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))

            Button("Sign Out", role: .destructive, action: signOut)
                .buttonStyle(DestructiveGlassButtonStyle())
        }
        .nightGlassCard()
    }

    private var loggedOutCard: some View {
        VStack(spacing: 18) {
            Image(systemName: "lock.slash")
                .font(.system(size: 52))
                .foregroundColor(.white.opacity(0.8))

            Text("You're not signed in")
                .font(.title3.weight(.semibold))
                .foregroundColor(.white)

            Text("Close this screen and return to the log in view to access your account settings.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.7))
        }
        .nightGlassCard()
    }

    private func glassField(
        title: String,
        text: Binding<String>,
        keyboard: UIKeyboardType = .default,
        autocapitalization: TextInputAutocapitalization = .sentences
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.75))

            TextField(title, text: text)
                .keyboardType(keyboard)
                .textInputAutocapitalization(autocapitalization)
                .autocorrectionDisabled(true)

                .foregroundColor(.white)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.white.opacity(0.18), lineWidth: 1)
                        )
                )
        }
    }


    private func glassSecureField(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.75))

            SecureField(title, text: text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .foregroundColor(.white)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.white.opacity(0.18), lineWidth: 1)
                        )
                )
        }
    }

    /// 根据当前账号填充输入框，支持实时响应登录状态变化
    private func populateFields() {
        guard let account = auth.currentAccount, auth.isAuthenticated else {
            clearFields()
            return
        }
        displayName = account.seller.nickname
        email = account.email
        location = account.location
        bio = account.bio
    }

    /// 尝试保存资料，成功后提示并留在页面
    private func saveProfile() {
        let result = auth.updateProfile(
            displayName: displayName,
            email: email,
            location: location,
            bio: bio
        )

        switch result {
        case .success:
            infoMessage = Feedback(message: "Profile updated successfully.", kind: .success)
        case .failure(let error):
            infoMessage = Feedback(message: error.localizedDescription, kind: .error)
        }
    }

    /// 调用 ViewModel 完成密码校验与更新
    private func updatePassword() {
        let result = auth.changePassword(
            currentPassword: currentPassword,
            newPassword: newPassword,
            confirmPassword: confirmPassword
        )

        switch result {
        case .success:
            passwordMessage = Feedback(message: "Password updated.", kind: .success)
            currentPassword = ""
            newPassword = ""
            confirmPassword = ""
        case .failure(let error):
            passwordMessage = Feedback(message: error.localizedDescription, kind: .error)
        }
    }

    /// 退出后重置所有本地状态并关闭页面
    private func signOut() {
        Task {
            auth.signOut()
            clearFields()
            infoMessage = nil
            passwordMessage = nil
            dismiss()
        }
    }


    /// 清理输入框，避免上一个账号的数据残留
    private func clearFields() {
        displayName = ""
        email = ""
        location = ""
        bio = ""
        currentPassword = ""
        newPassword = ""
        confirmPassword = ""
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthViewModel.previewAuthenticated())
    }
}
