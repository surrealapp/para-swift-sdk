import Foundation

public protocol AuthInfo: Codable {}

public struct EmailAuthInfo: AuthInfo {
    let email: String
    
    public init(email: String) {
        self.email = email
    }
}

public struct PhoneAuthInfo: AuthInfo {
    let phone: String
    let countryCode: String
    
    public init(phone: String, countryCode: String) {
        self.phone = phone
        self.countryCode = countryCode
    }
}

public enum ParaEnvironment: Hashable {
    case dev(relyingPartyId: String, jsBridgeUrl: URL?)
    case sandbox
    case beta
    case prod
    
    private var config: (relyingPartyId: String, jsBridgeUrl: URL, name: String) {
        switch self {
        case .dev(let relyingPartyId, let jsBridgeUrl):
            return (
                relyingPartyId,
                jsBridgeUrl ?? URL(string: "http://localhost:5173")!,
                "DEV"
            )
        case .sandbox:
            return (
                "app.sandbox.usecapsule.com",
                URL(string: "https://js-bridge.sandbox.usecapsule.com/")!,
                "SANDBOX"
            )
        case .beta:
            return (
                "app.beta.usecapsule.com",
                URL(string: "https://js-bridge.beta.usecapsule.com/")!,
                "BETA"
            )
        case .prod:
            return (
                "app.usecapsule.com",
                URL(string: "https://js-bridge.prod.usecapsule.com/")!,
                "PROD"
            )
        }
    }
    
    var relyingPartyId: String {
        config.relyingPartyId
    }
    
    var jsBridgeUrl: URL {
        config.jsBridgeUrl
    }
    
    var name: String {
        config.name
    }
}
