//
//  ContentView.swift
//  swift-example
//
//  Created by Brian Corbin on 4/19/24.
//

import SwiftUI

enum NavigationDestination {
    case verifyEmail, wallet
}

struct ContentView: View {
    
    @StateObject var jsBridgeViewModel = JSBridgeViewModel()
    @State private var email = ""
    @State private var path = [NavigationDestination]()
    
    @State private var showWalletView = false
    
    @Environment(\.authorizationController) private var authorizationController
        
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                JSBridgeWebView(viewModel: jsBridgeViewModel).ignoresSafeArea()
                VStack {
                    TextField("User Name (email address)", text: $email)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .border(.secondary)
                    Button("Sign Up") {
                        Task.init {
                            let userExists = await jsBridgeViewModel.checkIfUserExists(email: email)
                            
                            if userExists {
                                return
                            }
                            
                            await jsBridgeViewModel.createUser(email: email)
                            path.append(.verifyEmail)
                        }
                    }
                    Button("Log In") {
                        Task.init {
                            await jsBridgeViewModel.login(authorizationController: authorizationController)
                            path.append(.wallet)
                        }
                    }
                }
                .padding()
                .navigationDestination(for: NavigationDestination.self) { path in
                    switch path {
                    case .verifyEmail:
                        VerifyEmailView(email: email, path: $path).environmentObject(jsBridgeViewModel)
                    case .wallet:
                        WalletView(path: $path).environmentObject(jsBridgeViewModel)
                    }
                }
            }
        }
    }
}

struct VerifyEmailView: View {
    
    @EnvironmentObject var jsBridgeViewModel: JSBridgeViewModel
    
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
                let biometricsId = await jsBridgeViewModel.verify(verificationCode: code)
                await jsBridgeViewModel.generatePasskey(email: email, biometricsId: biometricsId, authorizationController: authorizationController)
                path.append(.wallet)
                await jsBridgeViewModel.createWallet(skipDistributable: false)
            }
        }
    }
}

struct WalletView: View {
    @EnvironmentObject var jsBridgeViewModel: JSBridgeViewModel
    
    @Binding var path: [NavigationDestination]
    
    var body: some View {
        VStack {
            if let wallet = jsBridgeViewModel.wallet {
                Text("Wallet Address: \(wallet.address!)")
                Button("Logout") {
                    Task.init {
                        await jsBridgeViewModel.logout()
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
