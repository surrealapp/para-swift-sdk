//
//  Capsule.swift
//  swift-example
//
//  Created by Brian Corbin on 4/23/24.
//

import SwiftUI
import UIKit
import WebKit
import AuthenticationServices

struct JSBridgeWebView: UIViewRepresentable {
    
    var viewModel: JSBridgeViewModel
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: CGRect.zero)
        webView.configuration.userContentController.add(viewModel, name: "callback")
        viewModel.webView = webView
        viewModel.loadJsBridge()
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
}

class JSBridgeViewModel: NSObject, ObservableObject, WKNavigationDelegate, WKScriptMessageHandler {
    private var continuation: CheckedContinuation<Any?, Error>?
    private let passkeysManager = PasskeysManager()

    @Published public var wallet: Wallet?
    
    weak var webView: WKWebView? {
        didSet {
            webView?.navigationDelegate = self
        }
    }

    var urlString = "http://localhost:3004/"
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let resp = message.body as! [String: Any]
        continuation?.resume(returning: resp["responseData"])
    }
    
    func loadJsBridge() {
        webView!.load(URLRequest(url: URL(string: urlString)!))
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        initCapsule()
    }
    
    private func initCapsule() {
        webView!.evaluateJavaScript("""
      window.postMessage({
        messageType: 'Capsule#init',
        arguments: {
          environment: 'DEV',
          apiKey: '6ffc4843fe246b31f7407f3324a39a70',
          platform: 'ios',
        }
      });
    """)
    }
    
    @MainActor
    private func postMessage(method: String, arguments: [Encodable]) async throws -> Any? {
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            webView!.evaluateJavaScript("""
          window.postMessage({
            'messageType': 'Capsule#invokeMethod',
            'methodName': '\(method)',
            'arguments': \(arguments)
          });
        """)
        }
    }
    
    func checkIfUserExists(email: String) async -> Bool {
        let result = try! await postMessage(method: "checkIfUserExists", arguments: [email])
        return result as! Bool
    }
    
    func createUser(email: String) async {
        try! await postMessage(method: "createUser", arguments: [email])
        return
    }
    
    func login(authorizationController: AuthorizationController) async {
        let getWebChallengeResult = try! await postMessage(method: "getWebChallenge", arguments: [])
        let challenge = (getWebChallengeResult as! [String: String])["challenge"]!
        let signIntoPasskeyAccountResult = try! await passkeysManager.signIntoPasskeyAccount(authorizationController: authorizationController, challenge: challenge)
        
        let id = signIntoPasskeyAccountResult.credentialID.base64URLEncodedString()
        let authenticatorData = signIntoPasskeyAccountResult.rawAuthenticatorData.base64URLEncodedString()
        let clientDataJSON = signIntoPasskeyAccountResult.rawClientDataJSON.base64URLEncodedString()
        let signature = signIntoPasskeyAccountResult.signature.base64URLEncodedString()
        
        let verifyWebChallengeResult = try! await postMessage(method: "verifyWebChallenge", arguments: [id, authenticatorData, clientDataJSON, signature])
        let userId = verifyWebChallengeResult as! String
        
        let wallet = try! await postMessage(method: "login", arguments: [userId, id, signIntoPasskeyAccountResult.userID.base64URLEncodedString()])
        self.wallet = Wallet(result: (wallet as! [String: Any]))
    }
    
    func verify(verificationCode: String) async -> String {
        let result = try! await postMessage(method: "verifyEmail", arguments: [verificationCode])
        let paths = (result as! String).split(separator: "/")
        let biometricsId = paths.last!.split(separator: "?").first!
        return String(biometricsId)
    }
    
    func generatePasskey(email: String, biometricsId: String, authorizationController: AuthorizationController) async {
        var userHandle = Data(count: 64)
        let _ = userHandle.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, 64, $0.baseAddress!)
        }
        
        let userHandleEncoded = userHandle.base64URLEncodedString()
        let result = try! await passkeysManager.createPasskeyAccount(authorizationController: authorizationController, username: email, userHandle: userHandle)
        
        let attestationObjectEncoded = result.rawAttestationObject!.base64URLEncodedString()
        let clientDataJSONEncoded = result.rawClientDataJSON.base64URLEncodedString()
        let credentialIDEncoded = result.credentialID.base64URLEncodedString()
        
        try! await postMessage(method: "generatePasskey", arguments: [attestationObjectEncoded, clientDataJSONEncoded, credentialIDEncoded, userHandleEncoded, biometricsId])
    }
    
    func createWallet(skipDistributable: Bool) async {
        let result = try! await postMessage(method: "createWallet", arguments: [skipDistributable])
        let walletAndRecovery = (result as! [[String: Any]])[0]
        self.wallet = Wallet(result: (walletAndRecovery["wallet"] as! [String: String]))
    }
    
    func logout() async {
        try! await postMessage(method: "logout", arguments: [])
        wallet = nil
    }
}

struct Wallet {
    let id: String
    let signer: String?
    let address: String?
    let publicKey: String?
    
    init(result: [String: Any]) {
        id = result["id"]! as! String
        signer = result["signer"] as? String
        address = result["address"] as? String
        publicKey = result["publicKey"] as? String
    }
}

extension Data {

    /// Instantiates data by decoding a base64url string into base64
    ///
    /// - Parameter string: A base64url encoded string
    init?(base64URLEncoded string: String) {
        self.init(base64Encoded: string.toggleBase64URLSafe(on: false))
    }

    /// Encodes the string into a base64url safe representation
    ///
    /// - Returns: A string that is base64 encoded but made safe for passing
    ///            in as a query parameter into a URL string
    func base64URLEncodedString() -> String {
        return self.base64EncodedString().toggleBase64URLSafe(on: true)
    }

}

extension String {

    /// Encodes or decodes into a base64url safe representation
    ///
    /// - Parameter on: Whether or not the string should be made safe for URL strings
    /// - Returns: if `on`, then a base64url string; if `off` then a base64 string
    func toggleBase64URLSafe(on: Bool) -> String {
        if on {
            // Make base64 string safe for passing into URL query params
            let base64url = self.replacingOccurrences(of: "/", with: "_")
                .replacingOccurrences(of: "+", with: "-")
                .replacingOccurrences(of: "=", with: "")
            return base64url
        } else {
            // Return to base64 encoding
            var base64 = self.replacingOccurrences(of: "_", with: "/")
                .replacingOccurrences(of: "-", with: "+")
            // Add any necessary padding with `=`
            if base64.count % 4 != 0 {
                base64.append(String(repeating: "=", count: 4 - base64.count % 4))
            }
            return base64
        }
    }

}

/*
 [0]    Substring    "http://localhost:3003/web/users/4af7b0f4-13f3-4820-a570-a27b708bce63/biometrics/5470f350-0adf-4590-9fef-377dcc841544?email=cwvrwjonjo%40test.usecapsule.com&partnerId=c0055eaf-a20e-4db6-aab7-174aa106edf8"
 */
