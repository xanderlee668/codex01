import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var auth: AuthViewModel
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var displayName: String = ""
    @State private var mode: Mode = .login

    private enum Mode: String, CaseIterable, Identifiable {
        case login = "Log In"
        case register = "Register"

        var id: String { rawValue }
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
                TabView {
                    ListingListView()
                        .environmentObject(auth.marketplace)
                        .tabItem {
                            Label("Marketplace", systemImage: "figure.snowboarding")
                        }

                    TripListView()
                        .environmentObject(auth.marketplace)
                        .tabItem {
                            Label("Group Trips", systemImage: "person.3")
                        }
                }
            } else {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Text("Snowboard Swap")
                            .font(.largeTitle)
                            .bold()
                        Text("Sign in to chat with riders across Europe or create a new account to start listing your gear.")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }

                    Picker("Auth Mode", selection: $mode) {
                        ForEach(Mode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)

                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Username")
                                .font(.headline)
                            TextField("Enter username", text: $username)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .padding(12)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(10)
                        }

                        if mode == .register {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Display name")
                                    .font(.headline)
                                TextField("Shown to other riders", text: $displayName)
                                    .textInputAutocapitalization(.words)
                                    .autocorrectionDisabled()
                                    .padding(12)
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(10)
                            }
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Password")
                                .font(.headline)
                            SecureField("Enter password", text: $password)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .padding(12)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(10)
                        }

                        if mode == .register {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Confirm password")
                                    .font(.headline)
                                SecureField("Re-enter password", text: $confirmPassword)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .padding(12)
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(10)
                            }
                        }
                    }

                    if let error = auth.authError {
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }

                    Button(action: authenticate) {
                        Text(actionButtonTitle)
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isActionDisabled ? Color.gray : Color.blue)
                            .cornerRadius(12)
                    }
                    .disabled(isActionDisabled)
                }
                .padding(32)
            }
        }
        .animation(.easeInOut, value: auth.isAuthenticated)
        .onChange(of: mode) { _ in
            auth.authError = nil
            password = ""
            confirmPassword = ""
        }
        .onChange(of: auth.isAuthenticated) { isAuthed in
            guard isAuthed else { return }
            username = ""
            password = ""
            confirmPassword = ""
            displayName = ""
        }
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
