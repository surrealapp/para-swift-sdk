import SwiftUI
import ParaSwift

enum NavigationDestination {
    case verifyEmail, wallet
}

struct UserAuthView: View {
    @EnvironmentObject var paraManager: ParaManager
    
    var body: some View {
        NavigationStack {
            List {
                // Single link for Email + Passkey Auth
                Section {
                    NavigationLink(destination: EmailAuthView()) {
                        AuthTypeView(
                            image: Image(systemName: "envelope"),
                            title: "Email + Passkey",
                            description: "Use your email to create or sign in with a passkey."
                        )
                    }
                }
                
                Section {
                    NavigationLink(destination: PhoneAuthView()) {
                        AuthTypeView(
                            image: Image(systemName: "phone"),
                            title: "Phone + Passkey",
                            description: "Use your phone number to create or sign in with a passkey."
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
