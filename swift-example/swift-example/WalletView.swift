//
//  WalletView.swift
//  swift-example
//
//  Created by Brian Corbin on 6/4/24.
//

import SwiftUI
import CapsuleSwift

struct WalletView: View {
    @EnvironmentObject var capsule: CapsuleSwift.Capsule 
    
    let wallet: Wallet?
    
    @Binding var path: [NavigationDestination]
    
    @State private var messageToSign = ""
    @State private var result = ""
    
    var body: some View {
        VStack {
            if let wallet = wallet {
                Spacer()
                Text("Wallet Address: \(wallet.address!)")
                
                TextField("Message to sign", text: $messageToSign)
                    .autocorrectionDisabled()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Sign Message") {
                    Task.init {
                        let messageSignature = try! await capsule.signMessage(walletId: wallet.id, message: messageToSign)
                        result = "messageSignature: \(messageSignature)"
                    }
                }.buttonStyle(.bordered)
                
                VStack {
                    HStack {
                        Button("Fully Logged In?") {
                            Task.init {
                                let isFullyLoggedIn = try! await capsule.isFullyLoggedIn()
                                result = "isFullyLoggedIn: \(isFullyLoggedIn)"
                            }
                        }
                        Button("Session Active?") {
                            Task.init {
                                let isSessionActive = try! await capsule.isSessionActive()
                                result = "isSessionActive: \(isSessionActive)"
                            }
                        }
                    }.buttonStyle(.bordered)
                    HStack {
                        Button("2FA Status") {
                            Task.init {
                                let status = try! await capsule.is2FASetup()
                                result = "2FA Status: \(status)"
                            }
                        }
                        Button("Setup 2FA") {
                            Task.init {
                                let status = try! await capsule.setup2FA()
                                result = "Setup 2FA: \(status)"
                            }
                        }
                        Button("Enable 2FA") {
                            Task.init {
                                try! await capsule.enable2FA()
                                result = "Enabled 2FA"
                            }
                        }
                    }.buttonStyle(.bordered)
                    HStack {
                        Button("Fetch Wallets") {
                            Task.init {
                                let wallets = try! await capsule.fetchWallets()
                                result = "Wallet addresses: \(wallets.map { $0.address })"
                            }
                        }
                    }.buttonStyle(.bordered)
                }
                
                Text("\(result)")
                
                Spacer()
                
                Button("Logout") {
                    Task.init {
                        try! await capsule.logout()
                        path = []
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
    WalletView(wallet: nil, path: .constant([])).environmentObject(CapsuleSwift.Capsule(environment: defaultDevEnv, apiKey: ""))
}

#Preview {
    WalletView(wallet: Wallet(id: "1", signer: nil, address: "0x1f328fejin3", publicKey: nil), path: .constant([])).environmentObject(CapsuleSwift.Capsule(environment: defaultDevEnv, apiKey: ""))
}
