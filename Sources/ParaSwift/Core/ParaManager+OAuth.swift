//
//  ParaManager+OAuth.swift
//  ParaSwift
//
//  Created by Brian Corbin on 2/11/25.
//

import SwiftUI
import AuthenticationServices

public enum OAuthProvider: String {
    case google = "GOOGLE"
    case discord = "DISCORD"
    case apple = "APPLE"
}

@available(iOS 16.4,*)
extension ParaManager {
    private func getOAuthURL(provider: OAuthProvider, deeplinkUrl: String) async throws -> String {
        let result = try await postMessage(method: "getOAuthURL", arguments: [provider.rawValue, deeplinkUrl])
        return try decodeResult(result, expectedType: String.self, method: "getOAuthURL")
    }
    
    public func oAuthConnect(provider: OAuthProvider, deeplinkUrl: String, webAuthenticationSession: WebAuthenticationSession) async throws -> String {
        let oAuthURL = try await getOAuthURL(provider: provider, deeplinkUrl: deeplinkUrl)
        guard let url = URL(string: oAuthURL) else {
            throw ParaError.error("Invalid url")
        }
        
        let urlWithToken = try await webAuthenticationSession.authenticate(using: url, callbackURLScheme: deeplinkUrl)
        guard let email = urlWithToken.valueOf("email") else {
            throw ParaError.error("No email found in returned url")
        }
        
        return email
    }
}
