import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                ListingListView()
            } else {
                VStack(spacing: 24) {
                    Image(systemName: "lock.circle")
                        .font(.system(size: 56))
                        .foregroundColor(.accentColor)
                    Text("登录后即可浏览雪板和私信卖家")
                        .font(.headline)
                    Button(action: authViewModel.completeDemoSignIn) {
                        Text("立即体验")
                            .font(.headline)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
            .environmentObject(AuthViewModel())
            .environmentObject(MarketplaceViewModel())
    }
}
