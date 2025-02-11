//
//  ParaManager+OAuth.swift
//  ParaSwift
//
//  Created by Brian Corbin on 2/11/25.
//

public enum OAuthProvider: String {
    case google = "GOOGLE"
    case discord = "DISCORD"
    case apple = "APPLE"
    case facebook = "FACEBOOK"
    case twitter = "TWITTER"
}

@available(iOS 16.4,*)
extension ParaManager {
    public func getOAuthURL(provider: OAuthProvider, deeplinkUrl: String) async throws -> String {
        let result = try await postMessage(method: "getOAuthURL", arguments: [provider.rawValue, deeplinkUrl])
        return try decodeResult(result, expectedType: String.self, method: "getOAuthURL")
    }
}
