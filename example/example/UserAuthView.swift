import SwiftUI
import CapsuleSwift

enum NavigationDestination {
    case verifyEmail, wallet
}

struct UserAuthView: View {
    @EnvironmentObject var capsuleManager: CapsuleManager
    
    var body: some View {
        NavigationStack {
            List {
                // Single link for Email + Passkey Auth
                Section {
                    NavigationLink(destination: EmailAuthView().environmentObject(capsuleManager)) {
                        AuthTypeView(
                            image: Image(systemName: "envelope"),
                            title: "Email + Passkey",
                            description: "Use your email to create or sign in with a passkey."
                        )
                    }
                }
            }
            .navigationTitle("Authentication")
            .listStyle(.insetGrouped)
        }
    }
}

struct AuthTypeView: View {
    let image: Image
    let title: String
    let description: String
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                image.font(.title).foregroundStyle(.red).padding(.trailing)
                Text(title).font(.title)
            }
            Text(description)
        }
    }
}
