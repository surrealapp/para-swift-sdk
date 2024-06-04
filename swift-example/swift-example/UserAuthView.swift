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

let defaultDevEnv = CapsuleEnvironment.dev(relyingPartyId: "optimum-seagull-discrete.ngrok-free.app", jsBridgeUrl: nil)
let defaultSandboxEnv = CapsuleEnvironment.sandbox(jsBridgeUrl: nil)
let defaultBetaEnv = CapsuleEnvironment.beta(jsBridgeUrl: nil)
let defaultProdEnv = CapsuleEnvironment.prod(jsBridgeUrl: nil)

struct UserAuthView: View {
    @StateObject var capsule = CapsuleSwift.Capsule(environment: defaultSandboxEnv, apiKey: "8ee2d015fbc6062a6e30bdc472f2946c")
    @State private var email = ""
    @State private var path = [NavigationDestination]()
    
    @State private var showWalletView = false
    @State private var selectedEnvironment = defaultSandboxEnv
    @State private var newApiKey: String = ""
    
    @State private var showingSetApiKeyAlert = false
    
    @Environment(\.authorizationController) private var authorizationController
        
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                CapsuleWebView(viewModel: capsule).hidden()
                VStack {
                    HStack {
                        Text("Environment")
                        if #available(iOS 17.0, *) {
                            Picker("Environment", selection: $selectedEnvironment) {
                                Text("Dev").tag(defaultDevEnv)
                                Text("Sandbox").tag(defaultSandboxEnv)
                                Text("Beta").tag(defaultBetaEnv)
                                Text("Prod").tag(defaultProdEnv)
                            }.onChange(of: selectedEnvironment) { oldValue, newValue in
                                capsule.environment = selectedEnvironment
                            }
                        } else {
                            // Fallback on earlier versions
                        }
                    }
                    
                    Button("Set API Key") {
                        showingSetApiKeyAlert.toggle()
                    }
                    .buttonStyle(.bordered)
                    .alert("", isPresented: $showingSetApiKeyAlert) {
                        TextField("API Key", text: $newApiKey)
                        Button("Set API Key") {
                            capsule.apiKey = newApiKey
                        }
                        Button("Cancel", role: .cancel) {
                            showingSetApiKeyAlert.toggle()
                        }
                    }
                    
                    Spacer()
                    
                    TextField("User Name (email address)", text: $email)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .border(.secondary)
                    HStack {
                        Button("Sign Up") {
                            Task.init {
                                let userExists = try! await capsule.checkIfUserExists(email: email)
                                
                                if userExists {
                                    return
                                }
                                
                                try! await capsule.createUser(email: email)
                                path.append(.verifyEmail)
                            }
                        }
                        Button("Log In") {
                            Task.init {
                                do {
                                    try await capsule.login(authorizationController: authorizationController)
                                    path.append(.wallet)
                                } catch {
                                    
                                }
                            }
                        }
                    }
                    .buttonStyle(.bordered)
                    Spacer()
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
