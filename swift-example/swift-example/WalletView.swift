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
            Spacer()
            if let wallet = wallet {
                Text("Wallet Address: \(wallet.address!)")
                
                TextField("Message to sign", text: $messageToSign)
                    .autocorrectionDisabled()
                    .border(.secondary)
                
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
                }
                
                Text("Result").font(.title).bold()
                Text("\(result)")
                
                Spacer()
                
                Button("Logout") {
                    Task.init {
                        await try! capsule.logout()
                        path = []
                    }
                }.buttonStyle(.bordered)
            } else {
                Text("Creating wallet...")
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    WalletView(wallet: nil, path: .constant([])).environmentObject(CapsuleSwift.Capsule(environment: .beta(jsBridgeUrl: nil), apiKey: ""))
}

#Preview {
    WalletView(wallet: Wallet(id: "1", signer: nil, address: "0x1f328fejin3", publicKey: nil), path: .constant([])).environmentObject(CapsuleSwift.Capsule(environment: .beta(jsBridgeUrl: nil), apiKey: ""))
}
