import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var auth: AuthViewModel
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
            Form {
                personalInformationSection
                changePasswordSection
            }
            .navigationTitle("Profile")
            .onAppear(perform: populateFields)
            .onChange(of: auth.currentAccount?.id) { _ in
                populateFields()
            }
        }
    }

    private var personalInformationSection: some View {
        Section(header: Text("Personal Information")) {
            TextField("Display Name", text: $displayName)
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            TextField("Location", text: $location)
            VStack(alignment: .leading, spacing: 4) {
                Text("Bio")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                TextEditor(text: $bio)
                    .frame(minHeight: 120)
            }

            if let message = infoMessage {
                Text(message.message)
                    .font(.footnote)
                    .foregroundColor(message.kind == .error ? .red : .green)
            }

            Button("Save Changes", action: saveProfile)
                .disabled(displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }

    private var changePasswordSection: some View {
        Section(header: Text("Change Password")) {
            SecureField("Current Password", text: $currentPassword)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            SecureField("New Password", text: $newPassword)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            SecureField("Confirm New Password", text: $confirmPassword)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            if let message = passwordMessage {
                Text(message.message)
                    .font(.footnote)
                    .foregroundColor(message.kind == .error ? .red : .green)
            }

            Button("Update Password", action: updatePassword)
                .disabled(currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty)
        }
    }

    private func populateFields() {
        guard let account = auth.currentAccount else { return }
        displayName = account.seller.nickname
        email = account.email
        location = account.location
        bio = account.bio
    }

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
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthViewModel(accounts: SampleData.accounts, initialAccount: SampleData.accounts.first, isAuthenticated: true))
    }
}
