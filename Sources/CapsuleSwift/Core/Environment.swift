//
//  File.swift
//  
//
//  Created by Brian Corbin on 6/3/24.
//

import Foundation

public enum CapsuleEnvironment: Hashable {
    case dev(relyingPartyId: String, jsBridgeUrl: URL?)
    case sandbox
    case beta
    case prod

    var relyingPartyId: String {
        switch self {
        case .dev(let relyingPartyId, _):
            return relyingPartyId
        case .sandbox:
            return "app.sandbox.usecapsule.com"
        case .beta:
            return "app.beta.usecapsule.com"
        case .prod:
            return "app.usecapsule.com"
        }
    }
    
    var jsBridgeUrl: URL {
        switch self {
        case .dev(_, let jsBridgeUrl):
            return jsBridgeUrl ?? URL(string: "http://localhost:5173")!
        case .sandbox:
            return URL(string: "https://js-bridge.sandbox.usecapsule.com/")!
        case .beta:
            return URL(string: "https://js-bridge.beta.usecapsule.com/")!
        case .prod:
            return URL(string: "https://js-bridge.prod.usecapsule.com/")!
        }
    }
    
    var name: String {
        switch self {
        case .dev(_ ,_):
            return "DEV"
        case .sandbox:
            return "SANDBOX"
        case .beta:
            return "BETA"
        case .prod:
            return "PROD"
        }
    }
}
