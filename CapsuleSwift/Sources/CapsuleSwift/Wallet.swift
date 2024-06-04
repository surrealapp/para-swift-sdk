//
//  File.swift
//  
//
//  Created by Brian Corbin on 6/4/24.
//

import Foundation

public struct Wallet {
    public let id: String
    public let signer: String?
    public let address: String?
    public let publicKey: String?
    
    public init(id: String, signer: String?, address: String?, publicKey: String?) {
        self.id = id
        self.signer = signer
        self.address = address
        self.publicKey = publicKey
    }
    
    public init(result: [String: Any]) {
        id = result["id"]! as! String
        signer = result["signer"] as? String
        address = result["address"] as? String
        publicKey = result["publicKey"] as? String
    }
}
