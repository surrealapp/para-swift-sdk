import SwiftUI
import ParaSwift

struct Transaction: Codable {
    let to: String
    let value: String
    let gasLimit: String
    let maxPriorityFeePerGas: String
    let maxFeePerGas: String
    let nonce: String
    let chainId: String
}

/*
 {
     "to": "0x42c9a72c9dfcc92cae0de9510160cea2da27af91",
     "value": "1000000000000",
     "gasLimit": "21000",
     "maxPriorityFeePerGas": "1",
     "maxFeePerGas": "3",
     "nonce": "0",
     "chainId": "11155111",
     "smartContractAbi": "[{\"inputs\":[],\"name\":\"retrieve\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"num\",\"type\":\"uint256\"}],\"name\":\"store\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"}]",
     "smartContractFunctionName": "",
     "smartContractFunctionArgs": [],
     "smartContractByteCode": "",
     "type": 2
 }
 */

struct WalletView: View {
    @EnvironmentObject var paraManager: ParaManager
    @EnvironmentObject var appRootManager: AppRootManager
    
    @State private var messageToSign = ""
    @State private var result = ""
    @State private var creatingWallet = false
    @State private var isSigning = false
    @State private var isFetching = false
    @State private var errorMessage: String?
    @State private var balance: Int?
    
    
//    private let web3 = Web3(provider: Web3HttpProvider(url: URL(string: "https://sepolia.infura.io/v3/961364684c7346c080994baab1469ea8")!, network: .Custom(networkID: 11155111)))
//    private let web3 = Web3(rpcURL: "https://sepolia.infura.io/v3/961364684c7346c080994baab1469ea8")
    
    func testingstuff() {
        
//        let b64RlpEncodedTx = "AuqDqjangAEDglIIlELJpyyd/Mksrg3pUQFgzqLaJ6+RhejUpRAAgMCAgIA="
        
//        Task {
//            let signedTx = try! await capsule.signTransaction(walletId: capsule.wallets.first!.id, rlpEncodedTx: rlpEncodedTx, chainId: "11155111")
//            print(signedTx)
//        }
        
//        let ethAddress = EthereumAddress(capsule.wallets.first!.address!)!
//        Task {
//            let balance = try! await web3.eth.getBalance(for: ethAddress)
//            self.balance = Int(balance)
//        }
                
//        let nonce = String(1, radix: 16)
//        let gasPrice = String(21000000000, radix: 16)
//        let gasLimit = String(21000, radix: 16)
//        let recipient = "c390cC49a32736a58733Cf46bE42f734dD4f53"
//        let value = String(1000000000000000000, radix: 16)
        
        let transaction = Transaction(to: "0x5bc5c2803A6ef66dEC048B39C6696d70673C507d", value: "1000000000000000000", gasLimit: "21000", maxPriorityFeePerGas: "1", maxFeePerGas: "3", nonce: "0", chainId: "11155111")
        let encodedTransaction = try! JSONEncoder().encode(transaction)
        let b64EncodedTransaction = encodedTransaction.base64EncodedString()
        
        
//        var values: [RLPValue] = []
//        values.append(.string(nonce))
//        values.append(.string(gasPrice))
//        values.append(.string(gasLimit))
//        values.append(.string(recipient))
//        values.append(.string(value))
//        
//        // 2. RLP-encode the unsigned part
//        let encoder = RLPEncoder()
//        let encodedTx = try! encoder.encode(.array(values))
//        let b64encodedTx = encodedTx.base64EncodedString()
        
//        let signatureHex = capsule.signTransaction(capsule.wallets.first!id, encodedTx.base64EncodedString(), chainId)
        Task {
            let rlpEncodedTx = try! await capsule.rlpEncodeTransaction(transactionb64: b64EncodedTransaction)
            let sigHex = try! await capsule.signTransaction(walletId: capsule.wallets.first!.id, rlpEncodedTx: rlpEncodedTx, chainId: "11155111")
            print(sigHex)
        }
//        var transaction2: CodableTransaction = .emptyTransaction
        
//        transaction.value = 100000
//        transaction.gasLimit = 78423
//        transaction.gasPrice = 2000000000

        
//        let hashForSig = transaction.hashForSignature()!
//        let b64Encoded = hashForSig.base64EncodedString()
//        
//        Task {
//            let signature = try! await capsule.signMessage(walletId: capsule.wallets.first!.id, message: b64Encoded)
//            print(signature)
//        }
        
//        firstly {
//            web3.eth.blockNumber()
//        }.then { blockNumber in
//            print(blockNumber)
//            return web3.eth.getBalance(address: EthereumAddress(hexString: capsule.wallets.first!.address!)!, block: .block(blockNumber.quantity))
//        }.done { balance in
//            print(balance)
//            self.balance = Int(balance.quantity)
//        }.catch { error in
//            print(error)
//        }

//
//        let transaction = EthereumTransaction(nonce: 1, gasPrice: 1000000000, gasLimit: 21000, from: EthereumAddress(hexString: capsule.wallets.first!.address!)!, to: EthereumAddress(hexString: "0x4be6f1633636bf8b62e6e43573e77d6968dd2a68")!, value: 500000000)
//
//        let jsonTransaction = try! JSONEncoder().encode(transaction)
//        let base64transaction = jsonTransaction.base64EncodedString()
//        
//        Task {
//            let signedTx = try! await capsule.signTransaction(walletId: capsule.wallets.first!.id, rlpEncodedTx: "AuqDqjangAEDglIIlELJpyyd/Mksrg3pUQFgzqLaJ6+RhejUpRAAgMCAgIA=", chainId: "11155111")
//            print(signedTx)
//        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to your Wallet Home")
                .font(.title2)
                .bold()
            
            if let firstWallet = paraManager.wallets.first {
                // Unwrap address safely
                let address = firstWallet.address ?? "No Address Available"
                
                Text("Wallet Address: \(address)")
                    .font(.body)
                    .padding(.horizontal)
            
                if let balance {
                    Text("Balance: \(balance)")
                }
                
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
                                throw ParaError.bridgeError("Failed to encode message.")
                            }
                            let messageSignature = try await paraManager.signMessage(walletId: firstWallet.id, message: base64Message)
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
                                let active = try await paraManager.isSessionActive()
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
                                let wallets = try await paraManager.fetchWallets()
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
                    
                    Button("Copy Address") {
                        UIPasteboard.general.string = capsule.wallets.first!.address!
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
                            try await paraManager.logout()
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
                            try await paraManager.createWallet(skipDistributable: false)
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
        .onAppear {
            testingstuff()
        }
    }
}
