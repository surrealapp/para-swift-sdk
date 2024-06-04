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
    @StateObject var capsule = CapsuleSwift.Capsule(environment: .dev(relyingPartyId: "optimum-seagull-discrete.ngrok-free.app", jsBridgeUrl: nil), apiKey: "f156a875cf80454f6cee85ab09059422")
    @State private var email = ""
    @State private var path = [NavigationDestination]()
    
    @State private var showWalletView = false
    
    @Environment(\.authorizationController) private var authorizationController
        
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                CapsuleWebView(viewModel: capsule).hidden()
                VStack {
                    TextField("User Name (email address)", text: $email)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .border(.secondary)
                    HStack {
                        Button("Sign Up") {
                            Task.init {
                                let userExists = await try! capsule.checkIfUserExists(email: email)
                                
                                if userExists {
                                    return
                                }
                                
                                await try! capsule.createUser(email: email)
                                path.append(.verifyEmail)
                            }
                        }
                        Button("Log In") {
                            Task.init {
                                await try! capsule.login(authorizationController: authorizationController)
                                path.append(.wallet)
                            }
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                .navigationDestination(for: NavigationDestination.self) { path in
                    switch path {
                    case .verifyEmail:
                        VerifyEmailView(email: email, path: $path).environmentObject(capsule)
                    case .wallet:
                        WalletView(wallet: capsule.wallet, path: $path).environmentObject(capsule)
                    }
                }
            }
        }
    }
}

#Preview {
    UserAuthView()
}
