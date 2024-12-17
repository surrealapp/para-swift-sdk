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
    
    @State private var creatingWallet = false
    
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
                }.buttonStyle(.bordered).disabled(messageToSign.isEmpty)
                
                VStack {
                    HStack {
                        Button("Session Active?") {
                            Task.init {
                                let isSessionActive = try await capsule.isSessionActive()
                                result = "isSessionActive: \(isSessionActive)"
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
                Button {
                    Task.init {
                        creatingWallet = true
                        try await capsule.createWallet(skipDistributable: false)
                        creatingWallet = false
                    }
                } label: {
                    Group {
                        if (creatingWallet) {
                            HStack {
                                Text("Creating Wallet...")
                                ProgressView()
                            }
                        } else {
                            Text("Create Wallet")
                        }
                    }.frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    WalletView().environmentObject(CapsuleManager(environment: .sandbox, apiKey: ""))
}
