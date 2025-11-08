import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var auth: AuthViewModel
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var displayName: String = ""
    @State private var mode: Mode = .login
    @State private var selectedTab: Tab = .marketplace

    private enum Mode: String, CaseIterable, Identifiable {
        case login = "Log In"
        case register = "Register"

        var id: String { rawValue }
    }

    private enum Tab: Hashable {
        case marketplace
        case groupTrips
    }

    private var actionButtonTitle: String {
        mode == .login ? "Log In" : "Create Account"
    }

    private var isActionDisabled: Bool {
        switch mode {
        case .login:
            return username.isEmpty || password.isEmpty
        case .register:
            return username.isEmpty || password.isEmpty || confirmPassword.isEmpty
        }
    }

    var body: some View {
        Group {
            if auth.isAuthenticated {
                // 登录成功后展示主业务 Tab
                TabView {
                    ListingListView()
                        .environmentObject(auth.marketplace)
                        .tag(Tab.marketplace)
                        .tabItem {
                            Label("Marketplace", systemImage: "figure.snowboarding")
                        }

                    TripListView()
                        .environmentObject(auth.marketplace)
                        .tag(Tab.groupTrips)
                        .tabItem {
                            Label("Group Trips", systemImage: "person.3")
                        }

                }
            } else {
                // 登录 / 注册表单
                ScrollView {
                    VStack(spacing: 28) {
                        VStack(spacing: 12) {
                            Text("Snowboard Swap")
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(.white)
                            Text("Sign in to chat with riders across Europe or create a new account to start listing your gear.")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white.opacity(0.75))
                        }
                        .nightGlassCard()

                        VStack(alignment: .leading, spacing: 20) {
                            Picker("Auth Mode", selection: $mode) {
                                ForEach(Mode.allCases) { mode in
                                    Text(mode.rawValue).tag(mode)
                                }
                            }
                            .pickerStyle(.segmented)
                            .colorScheme(.dark)

                            VStack(alignment: .leading, spacing: 18) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Username")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    TextField("Enter username", text: $username)
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled()
                                        .padding(12)
                                        .background(Color.white.opacity(0.08))
                                        .cornerRadius(12)
                                }

                                if mode == .register {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Display name")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        TextField("Shown to other riders", text: $displayName)
                                            .textInputAutocapitalization(.words)
                                            .autocorrectionDisabled()
                                            .padding(12)
                                            .background(Color.white.opacity(0.08))
                                            .cornerRadius(12)
                                    }
                                }

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Password")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    SecureField("Enter password", text: $password)
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled()
                                        .padding(12)
                                        .background(Color.white.opacity(0.08))
                                        .cornerRadius(12)
                                }

                                if mode == .register {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Confirm password")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        SecureField("Re-enter password", text: $confirmPassword)
                                            .textInputAutocapitalization(.never)
                                            .autocorrectionDisabled()
                                            .padding(12)
                                            .background(Color.white.opacity(0.08))
                                            .cornerRadius(12)
                                    }
                                }
                            }

                            if let error = auth.authError {
                                Text(error)
                                    .font(.subheadline)
                                    .foregroundColor(.red.opacity(0.8))
                                    .multilineTextAlignment(.center)
                            }

                            Button(action: authenticate) {
                                Text(actionButtonTitle)
                            }
                            .buttonStyle(PrimaryGlassButtonStyle())
                            .opacity(isActionDisabled ? 0.6 : 1)
                            .disabled(isActionDisabled)
                        }
                        .nightGlassCard()
                    }
                    .padding(.vertical, 48)
                    .padding(.horizontal, 28)
                }
            }
        }
        .animation(.easeInOut, value: auth.isAuthenticated)
        // 切换模式时清理密码并重置错误
        .onChange(of: mode) { _ in
            auth.authError = nil
            password = ""
            confirmPassword = ""
        }
        // 登录成功后清空输入，避免下次自动填充
        .onChange(of: auth.isAuthenticated) { isAuthed in
            guard isAuthed else { return }
            username = ""
            password = ""
            confirmPassword = ""
            displayName = ""
        }
        .background(NightGradientBackground())
        .preferredColorScheme(.dark)
    }

    private func authenticate() {
        switch mode {
        case .login:
            auth.signIn(username: username, password: password)
        case .register:
            guard password == confirmPassword else {
                auth.authError = "Passwords do not match."
                return
            }
            auth.register(username: username, password: password, displayName: displayName)
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
            .environmentObject(AuthViewModel())
    }
}
