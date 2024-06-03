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

struct ContentView: View {
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
                .padding()
                .navigationDestination(for: NavigationDestination.self) { path in
                    switch path {
                    case .verifyEmail:
                        VerifyEmailView(email: email, path: $path).environmentObject(capsule)
                    case .wallet:
                        WalletView(path: $path).environmentObject(capsule)
                    }
                }
            }
        }
    }
}

struct VerifyEmailView: View {
    
    @EnvironmentObject var capsule: CapsuleSwift.Capsule
    
    let email: String
    
    @State private var code = ""
    @Binding var path: [NavigationDestination]
    
    @Environment(\.authorizationController) private var authorizationController
        
    var body: some View {
        TextField("Code", text: $code)
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            .border(.secondary)
        Button("Verify") {
            Task.init {
                let biometricsId = await try! capsule.verify(verificationCode: code)
                await try! capsule.generatePasskey(email: email, biometricsId: biometricsId, authorizationController: authorizationController)
                path.append(.wallet)
                await try! capsule.createWallet(skipDistributable: false)
            }
        }
    }
}

struct WalletView: View {
    @EnvironmentObject var capsule: CapsuleSwift.Capsule
    
    @Binding var path: [NavigationDestination]
    
    @State private var messageToSign = ""
    @State private var signedMessage = ""
    
    var body: some View {
        VStack {
            if let wallet = capsule.wallet {
                Text("Wallet Address: \(wallet.address!)")
                
                TextField("Message to sign", text: $messageToSign)
                
                Button("Sign Message") {
                    Task.init {
                        signedMessage = await try! capsule.signMessage(walletId: wallet.id, message: messageToSign)
                    }
                }
                
                Text("Signed Message: \(signedMessage)")
                
                Button("Logout") {
                    Task.init {
                        await try! capsule.logout()
                        path = []
                    }
                }
            } else {
                Text("Creating wallet...")
            }
        }
    }
}

#Preview {
    ContentView()
}
