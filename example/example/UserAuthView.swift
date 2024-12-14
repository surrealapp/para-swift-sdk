//
//  ContentView.swift
//  swift-example
//
//  Created by Brian Corbin on 4/19/24.
//

import SwiftUI
import CapsuleSwift

enum NavigationDestination {
    case verifyEmail, wallet
}

struct UserAuthView: View {
    @EnvironmentObject var capsuleManager: CapsuleManager
        
    var body: some View {
        NavigationStack {
            ZStack {
                CapsuleWebView(capsuleManager: capsuleManager).hidden()
                List {
                    NavigationLink(destination: EmailAuthView().environmentObject(capsuleManager)) {
                        AuthTypeView(image: Image(systemName: "envelope"), title: "Email + Passkey Authentication", description: "Implement email based authentication with passkey support for enhanced security")
                    }
                }
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
        VStack (alignment: .leading) {
            HStack {
                image.font(.title).foregroundStyle(.red).padding(.trailing)
                Text(title).font(.title)
            }
            Text(description)
        }
    }
}

#Preview("User Auth") {
    UserAuthView().environmentObject(CapsuleManager(environment: .sandbox, apiKey: "vesbrsbtevrwce"))
}

#Preview("Auth Type") {
    AuthTypeView(image: Image(systemName: "envelope"), title: "Email + Passkey Authentication", description: "Implement email based authentication with passkey support for enhanced security")
}
