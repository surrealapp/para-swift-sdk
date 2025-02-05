//
//  ParaEvmSigner.swift
//  ParaSwift
//
//  Created by Brian Corbin on 2/5/25.
//

import Foundation

public struct EVMTransaction: Codable {
    let to: String?
    let value: String?
    let gasLimit: String?
    let gasPrice: String?
    let maxPriorityFeePerGas: String?
    let maxFeePerGas: String?
    let nonce: String?
    let chainId: String?
    let smartContractAbi: String?
    let smartContractFunctionName: String?
    let smartContractFunctionArgs: [String]?
    let smartContractByteCode: String?
    let type: Int?
    
    public init(to: String?, value: String?, gasLimit: String?, gasPrice: String?, maxPriorityFeePerGas: String?, maxFeePerGas: String?, nonce: String?, chainId: String?, smartContractAbi: String?, smartContractFunctionName: String?, smartContractFunctionArgs: [String]?, smartContractByteCode: String?, type: Int?) {
        self.to = to
        self.value = value
        self.gasLimit = gasLimit
        self.gasPrice = gasPrice
        self.maxPriorityFeePerGas = maxPriorityFeePerGas
        self.maxFeePerGas = maxFeePerGas
        self.nonce = nonce
        self.chainId = chainId
        self.smartContractAbi = smartContractAbi
        self.smartContractFunctionName = smartContractFunctionName
        self.smartContractFunctionArgs = smartContractFunctionArgs
        self.smartContractByteCode = smartContractByteCode
        self.type = type
    }
    
    public func b64Encoded() -> String {
        let encodedTransaction = try! JSONEncoder().encode(self)
        return encodedTransaction.base64EncodedString()
    }
}

@available(iOS 16.4, *)
@MainActor
public class ParaEvmSigner: ObservableObject {
    private let paraManager: ParaManager
    private let rpcUrl: String
    
    public init(paraManager: ParaManager, rpcUrl: String, walletId: String?) throws {
        self.paraManager = paraManager
        self.rpcUrl = rpcUrl
        
        if let walletId {
            Task {
                try await selectWallet(walletId: walletId)
            }
        }
    }
    
    private func initEthersSigner(rpcUrl: String, walletId: String) async throws {
        let _ = try await paraManager.postMessage(method: "initEthersSigner", arguments: [walletId, rpcUrl])
    }
    
    public func selectWallet(walletId: String) async throws {
        try await initEthersSigner(rpcUrl: self.rpcUrl, walletId: walletId)
    }
    
    public func signMessage(message: String) async throws -> String {
        let result = try await paraManager.postMessage(method: "ethersSignMessage", arguments: [message])
        return try paraManager.decodeResult(result, expectedType: String.self, method: "ethersSignMessage")
    }
    
    public func signTransaction(transactionB64: String) async throws -> String {
        let result = try await paraManager.postMessage(method: "ethersSignTransaction", arguments: [transactionB64])
        return try paraManager.decodeResult(result, expectedType: String.self, method: "ethersSignTransaction")
    }
    
    public func sendTransaction(transactionB64: String) async throws -> Any {
        let result = try await paraManager.postMessage(method: "ethersSendTransaction", arguments: [transactionB64])
        return result!
    }
}
