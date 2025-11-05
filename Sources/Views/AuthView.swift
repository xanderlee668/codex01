import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var auth: AuthViewModel
    @State private var mode: AuthMode = .login
    @State private var displayName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @FocusState private var focusedField: Field?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    Picker("模式", selection: $mode) {
                        ForEach(AuthMode.allCases) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)

                    VStack(alignment: .leading, spacing: 16) {
                        if mode == .register {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("昵称")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                TextField("给自己起个昵称", text: $displayName)
                                    .textInputAutocapitalization(.words)
                                    .textContentType(.nickname)
                                    .submitLabel(.next)
                                    .focused($focusedField, equals: .displayName)
                                    .authFieldStyle()
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("邮箱")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            TextField("请输入邮箱", text: $email)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .textContentType(.emailAddress)
                                .autocorrectionDisabled()
                                .submitLabel(.next)
                                .focused($focusedField, equals: .email)
                                .authFieldStyle()
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("密码")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            SecureField("请输入密码", text: $password)
                                .textContentType(mode == .register ? .newPassword : .password)
                                .submitLabel(mode == .login ? .go : .next)
                                .focused($focusedField, equals: .password)
                                .authFieldStyle()
                        }

                        if mode == .register {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("确认密码")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                SecureField("再次输入密码", text: $confirmPassword)
                                    .textContentType(.newPassword)
                                    .submitLabel(.go)
                                    .focused($focusedField, equals: .confirmPassword)
                                    .authFieldStyle()
                            }

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
                        if mode == .register {
                            SecureField("再次输入密码", text: $confirmPassword)
                        }
                    }

                    if let message = auth.errorMessage {
                        Text(message)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button(action: submit) {
                        Text(mode.buttonTitle)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isFormValid ? Color.accentColor : Color.accentColor.opacity(0.4))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(!isFormValid)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle(mode.navigationTitle)
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
                focusedField = mode == .register ? .displayName : .email
            }
            .onAppear {
                focusedField = .email
            }
            .onSubmit(handleSubmitAction)
            }
        }
    }

    private var isFormValid: Bool {
        switch mode {
        case .login:
            return !trimmedEmail.isEmpty && !password.isEmpty
        case .register:
            return !trimmedDisplayName.isEmpty &&
                !trimmedEmail.isEmpty &&
                password.count >= 6 &&
                password == confirmPassword
        }
    }

    private var trimmedEmail: String {
        email.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedDisplayName: String {
        displayName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func handleSubmitAction() {
        switch focusedField {
        case .displayName:
            focusedField = .email
        case .email:
            focusedField = .password
        case .password:
            if mode == .login {
                submit()
            } else {
                focusedField = .confirmPassword
            }
        case .confirmPassword:
            submit()
        case .none:
            submit()
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
            auth.login(email: trimmedEmail, password: password)
        case .register:
            if auth.register(displayName: trimmedDisplayName, email: trimmedEmail, password: password, confirmPassword: confirmPassword) {
                clearFields()
            }
        }
        if auth.errorMessage == nil {
            focusedField = nil
        }
    }

    private func clearFields() {
        displayName = ""
        email = ""
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

private enum Field: Hashable {
    case displayName
    case email
    case password
    case confirmPassword
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

private struct AuthFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 12)
            .padding(.horizontal)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
    }
}

private extension View {
    func authFieldStyle() -> some View {
        modifier(AuthFieldStyle())
    }
}
