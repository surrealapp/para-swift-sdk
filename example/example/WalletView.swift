import SwiftUI
import CapsuleSwift

struct WalletView: View {
    @EnvironmentObject var capsule: CapsuleManager
    @EnvironmentObject var appRootManager: AppRootManager
    
    @State private var messageToSign = ""
    @State private var result = ""
    @State private var creatingWallet = false
    @State private var isSigning = false
    @State private var isFetching = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to your Wallet Home")
                .font(.title2)
                .bold()
            
            if let firstWallet = capsule.wallets.first {
                // Unwrap address safely
                let address = firstWallet.address ?? "No Address Available"
                
                Text("Wallet Address: \(address)")
                    .font(.body)
                    .padding(.horizontal)
                
                TextField("Enter a message to sign", text: $messageToSign)
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                if isSigning {
                    ProgressView("Signing message...")
                }
                
                Button("Sign Message") {
                    guard !messageToSign.isEmpty else {
                        errorMessage = "Please enter a message to sign."
                        return
                    }
                    isSigning = true
                    errorMessage = nil
                    Task {
                        do {
                            let messageBytes = messageToSign.data(using: .utf8)
                            guard let base64Message = messageBytes?.base64EncodedString() else {
                                throw CapsuleError.bridgeError("Failed to encode message.")
                            }
                            let messageSignature = try await capsule.signMessage(walletId: firstWallet.id, message: base64Message)
                            result = "Message Signature: \(messageSignature)"
                            isSigning = false
                        } catch {
                            isSigning = false
                            errorMessage = "Failed to sign message: \(error.localizedDescription)"
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isSigning || messageToSign.isEmpty)
                .padding(.horizontal)
                
                if isFetching {
                    ProgressView("Fetching wallets...")
                }
                
                // Buttons for session/wallet actions
                HStack {
                    Button("Check Session Active") {
                        isFetching = true
                        errorMessage = nil
                        Task {
                            do {
                                let active = try await capsule.isSessionActive()
                                result = "Session Active: \(active)"
                                isFetching = false
                            } catch {
                                isFetching = false
                                errorMessage = "Failed to check session: \(error.localizedDescription)"
                            }
                        }
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Fetch Wallets") {
                        isFetching = true
                        errorMessage = nil
                        Task {
                            do {
                                let wallets = try await capsule.fetchWallets()
                                let addresses = wallets.map { $0.address ?? "No Address" }
                                result = "Wallet addresses: \(addresses.joined(separator: ", "))"
                                isFetching = false
                            } catch {
                                isFetching = false
                                errorMessage = "Failed to fetch wallets: \(error.localizedDescription)"
                            }
                        }
                    }
                    .buttonStyle(.bordered)
                }
                
                Text(result)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                
                Spacer()
                
                Button("Logout") {
                    Task {
                        errorMessage = nil
                        do {
                            try await capsule.logout()
                            appRootManager.currentRoot = .authentication
                        } catch {
                            errorMessage = "Failed to logout: \(error.localizedDescription)"
                        }
                    }
                }
                .buttonStyle(.bordered)
            } else {
                // No wallets found
                Text("No wallets found. Create one to get started.")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                if creatingWallet {
                    ProgressView("Creating Wallet...")
                }
                
                Button("Create Wallet") {
                    creatingWallet = true
                    errorMessage = nil
                    Task {
                        do {
                            try await capsule.createWallet(skipDistributable: false)
                            creatingWallet = false
                        } catch {
                            creatingWallet = false
                            errorMessage = "Failed to create wallet: \(error.localizedDescription)"
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(creatingWallet)
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .padding()
        .navigationTitle("Home")
    }
}
