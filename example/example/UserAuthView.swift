import SwiftUI
import CapsuleSwift

enum NavigationDestination {
    case verifyEmail, wallet
}

struct UserAuthView: View {
    @EnvironmentObject var capsuleManager: CapsuleManager
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Select an Authentication Method")
                    .font(.title2)
                    .bold()
                    .padding(.top)

                // Single link for Email + Passkey Auth
                NavigationLink(destination: EmailAuthView().environmentObject(capsuleManager)) {
                    AuthTypeView(
                        image: Image(systemName: "envelope"),
                        title: "Email + Passkey",
                        description: "Use your email to create or sign in with a passkey."
                    )
                }
                .buttonStyle(.bordered)
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Authentication")
        }
    }
}

struct AuthTypeView: View {
    let image: Image
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 10) {
            image
                .font(.title)
                .foregroundStyle(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
