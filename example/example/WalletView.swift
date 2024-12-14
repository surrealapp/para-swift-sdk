//
//  WalletView.swift
//  swift-example
//
//  Created by Brian Corbin on 6/4/24.
//

import SwiftUI
import CapsuleSwift

struct WalletView: View {
    @EnvironmentObject var capsule: CapsuleManager
    @EnvironmentObject var appRootManager: AppRootManager
        
    @State private var messageToSign = ""
    @State private var result = ""
    
    var body: some View {
        VStack {
            if let wallet = capsule.wallets.first {
                Spacer()
                Text("Wallet Address: \(wallet.address!)")
                
                TextField("Message to sign", text: $messageToSign)
                    .autocorrectionDisabled()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Sign Message") {
                    Task.init {
                        let messageBytes = messageToSign.data(using: .utf8)
                        let messageBase64 = messageBytes?.base64EncodedString()
                        let messageSignature = try await capsule.signMessage(walletId: wallet.id, message: messageBase64!)
                        result = "messageSignature: \(messageSignature)"
                    }
                }.buttonStyle(.bordered)
                
                VStack {
                    HStack {
                        Button("Fully Logged In?") {
                            Task.init {
                                let isFullyLoggedIn = try await capsule.isFullyLoggedIn()
                                result = "isFullyLoggedIn: \(isFullyLoggedIn)"
                            }
                        }
                        Button("Session Active?") {
                            Task.init {
                                let isSessionActive = try await capsule.isSessionActive()
                                result = "isSessionActive: \(isSessionActive)"
                            }
                        }
                    }.buttonStyle(.bordered)
                    HStack {
                        Button("2FA Status") {
                            Task.init {
                                let status = try await capsule.is2FASetup()
                                result = "2FA Status: \(status)"
                            }
                        }
                        Button("Setup 2FA") {
                            Task.init {
                                let status = try await capsule.setup2FA()
                                result = "Setup 2FA: \(status)"
                            }
                        }
                        Button("Enable 2FA") {
                            Task.init {
                                try await capsule.enable2FA()
                                result = "Enabled 2FA"
                            }
                        }
                    }.buttonStyle(.bordered)
                    HStack {
                        Button("Fetch Wallets") {
                            Task.init {
                                let wallets = try await capsule.fetchWallets()
                                result = "Wallet addresses: \(wallets.map { $0.address })"
                            }
                        }
                    }.buttonStyle(.bordered)
                }
                
                Text("\(result)")
                
                Spacer()
                
                Button("Logout") {
                    Task.init {
                        try await capsule.logout()
                        appRootManager.currentRoot = .authentication
                    }
                }.buttonStyle(.bordered)
            } else {
                ProgressView()
                Text("Creating wallet...")
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    WalletView().environmentObject(CapsuleManager(environment: .sandbox, apiKey: ""))
}
