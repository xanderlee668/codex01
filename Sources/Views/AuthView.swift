import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var auth: AuthViewModel
    @State private var username: String = ""
    @State private var password: String = ""

    var body: some View {
        Group {
            if auth.isAuthenticated {
                ListingListView()
                    .environmentObject(auth.marketplace)
            } else {
                VStack(spacing: 24) {
                    Text("欢迎回来")
                        .font(.largeTitle)
                        .bold()

                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("用户名")
                                .font(.headline)
                            TextField("输入用户名", text: $username)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .padding(12)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(10)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("密码")
                                .font(.headline)
                            SecureField("输入密码", text: $password)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .padding(12)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(10)
                        }
                    }

                    Button(action: authenticate) {
                        Text("登录")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(username.isEmpty || password.isEmpty ? Color.gray : Color.blue)
                            .cornerRadius(12)
                    }
                    .disabled(username.isEmpty || password.isEmpty)
                }
                .padding(32)
            }
        }
        .animation(.easeInOut, value: auth.isAuthenticated)
    }

    private func authenticate() {
        guard !username.isEmpty, !password.isEmpty else { return }
        auth.signIn()
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
            .environmentObject(AuthViewModel())
    }
}
