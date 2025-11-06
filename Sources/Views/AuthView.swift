import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var auth: AuthViewModel
    @State private var mode: AuthMode = .login
    @State private var displayName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Picker("模式", selection: $mode) {
                    ForEach(AuthMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.top)

                Form {
                    if mode == .register {
                        Section(header: Text("昵称")) {
                            TextField("给自己起个昵称", text: $displayName)
                                .textInputAutocapitalization(.never)
                        }
                    }

                    Section(header: Text("邮箱")) {
                        TextField("请输入邮箱", text: $email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }

                    Section(header: Text("密码")) {
                        SecureField("请输入密码", text: $password)
                            .textContentType(.password)
                            .textInputAutocapitalization(.never)
                        if mode == .register {
                            SecureField("再次输入密码", text: $confirmPassword)
                                .textContentType(.password)
                                .textInputAutocapitalization(.never)
                        }
                    }

                    if let message = auth.errorMessage {
                        Section {
                            Text(message)
                                .foregroundColor(.red)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color(.systemGroupedBackground))

                Button(action: submit) {
                    Text(mode.buttonTitle)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(!isFormValid)
                .padding(.horizontal)
            }
            .navigationTitle(mode.navigationTitle)
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .onChange(of: mode) { _ in
                auth.errorMessage = nil
                password = ""
                confirmPassword = ""
            }
        }
    }

    private var isFormValid: Bool {
        switch mode {
        case .login:
            return !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !password.isEmpty
        case .register:
            return !displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                !password.isEmpty &&
                !confirmPassword.isEmpty
        }
    }

    private func submit() {
        switch mode {
        case .login:
            auth.login(email: email, password: password)
        case .register:
            if auth.register(displayName: displayName, email: email, password: password, confirmPassword: confirmPassword) {
                clearFields()
            }
        }
    }

    private func clearFields() {
        password = ""
        confirmPassword = ""
    }
}

private enum AuthMode: String, CaseIterable, Identifiable {
    case login
    case register

    var id: String { rawValue }

    var title: String {
        switch self {
        case .login: return "登录"
        case .register: return "注册"
        }
    }

    var buttonTitle: String {
        switch self {
        case .login: return "立即登录"
        case .register: return "创建账号"
        }
    }

    var navigationTitle: String {
        switch self {
        case .login: return "欢迎回来"
        case .register: return "加入雪板集市"
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
            .environmentObject(AuthViewModel())
    }
}
