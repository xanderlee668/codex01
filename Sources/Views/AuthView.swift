import SwiftUI
import UIKit

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
                    ForEach(AuthMode.allCases) { selection in
                        Text(selection.title).tag(selection)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())

                VStack(alignment: .leading, spacing: 16) {
                    if mode == .register {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("昵称")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            TextField("给自己起个昵称", text: $displayName)
                                .autocapitalization(.words)
                                .textContentType(.nickname)
                                .disableAutocorrection(true)
                                .authFieldStyle()
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("邮箱")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        TextField("请输入邮箱", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .textContentType(.emailAddress)
                            .disableAutocorrection(true)
                            .authFieldStyle()
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("密码")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        SecureInputField(placeholder: "请输入密码", text: $password)
                            .authFieldStyle()
                    }

                    if mode == .register {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("确认密码")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            SecureInputField(placeholder: "再次输入密码", text: $confirmPassword)
                                .authFieldStyle()
                        }
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

                Spacer()
            }
            .padding()
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle(mode.navigationTitle)
            .onChange(of: mode) { _ in
                auth.errorMessage = nil
                password = ""
                confirmPassword = ""
                if mode == .register {
                    displayName = ""
                }
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

    private func submit() {
        switch mode {
        case .login:
            auth.login(email: trimmedEmail, password: password)
        case .register:
            if auth.register(displayName: trimmedDisplayName, email: trimmedEmail, password: password, confirmPassword: confirmPassword) {
                clearFields()
            }
        }
    }

    private func clearFields() {
        displayName = ""
        email = ""
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

private struct AuthFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 12)
            .padding(.horizontal)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
    }
}

private struct SecureInputField: UIViewRepresentable {
    final class Coordinator: NSObject, UITextFieldDelegate {
        let parent: SecureInputField

        init(parent: SecureInputField) {
            self.parent = parent
        }

        @objc
        func textChanged(_ sender: UITextField) {
            parent.text = sender.text ?? ""
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
    }

    var placeholder: String
    @Binding var text: String

    func makeUIView(context: Context) -> UITextField {
        let field = UITextField()
        field.placeholder = placeholder
        field.isSecureTextEntry = true
        field.textContentType = .password
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.smartQuotesType = .no
        field.smartDashesType = .no
        field.spellCheckingType = .no
        field.keyboardType = .default
        field.returnKeyType = .done
        field.delegate = context.coordinator
        field.addTarget(context.coordinator, action: #selector(Coordinator.textChanged(_:)), for: .editingChanged)
        field.font = UIFont.preferredFont(forTextStyle: .body)
        field.passwordRules = nil
        return field
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}

private extension View {
    func authFieldStyle() -> some View {
        modifier(AuthFieldStyle())
    }
}
