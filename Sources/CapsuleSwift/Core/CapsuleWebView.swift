import SwiftUI
import WebKit
import os

@available(iOS 16.4, macOS 10.15, *)
@MainActor
public class CapsuleWebView: NSObject, ObservableObject {
    @Published public private(set) var isReady: Bool = false
    @Published public var initializationError: Error?
    @Published public var lastError: Error?
    
    public var environment: CapsuleEnvironment
    public var apiKey: String
    public static let packageVersion = "0.0.3"
    
    private let webView: WKWebView
    private var requestTimeout: TimeInterval
    
    private var pendingRequests: [String: (continuation: CheckedContinuation<Any?, Error>, timeoutTask: Task<Void, Never>?)] = [:]
    private var isCapsuleInitialized = false
    
    public init(environment: CapsuleEnvironment, apiKey: String, requestTimeout: TimeInterval = 30.0) {
        self.environment = environment
        self.apiKey = apiKey
        self.requestTimeout = requestTimeout
        
        let config = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        config.userContentController = userContentController
        self.webView = WKWebView(frame: .zero, configuration: config)
        
        super.init()
        
        userContentController.add(LeakAvoider(delegate: self), name: "callback")
        self.webView.navigationDelegate = self
        
        loadBridge()
    }
    
    @discardableResult
    public func postMessage(method: String, arguments: [Encodable]) async throws -> Any? {
        guard isReady else {
            throw CapsuleWebViewError.webViewNotReady
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let requestId = "req-\(UUID().uuidString)"
            
            let encodedArgs: Any
            do {
                let data = try JSONEncoder().encode(arguments.map { AnyEncodable($0) })
                encodedArgs = try JSONSerialization.jsonObject(with: data, options: [])
            } catch {
                continuation.resume(throwing: CapsuleWebViewError.invalidArguments("Failed to encode arguments"))
                return
            }
            
            let message: [String: Any] = [
                "messageType": "Capsule#invokeMethod",
                "methodName": method,
                "arguments": encodedArgs,
                "requestId": requestId
            ]
            
            guard let jsonData = try? JSONSerialization.data(withJSONObject: message, options: []),
                  let jsonString = String(data: jsonData, encoding: .utf8) else {
                continuation.resume(throwing: CapsuleWebViewError.invalidArguments("Unable to serialize message"))
                return
            }
            
            // Insert into pending requests before evaluating JS
            // We'll create a timeout task to handle request timeouts
            let timeoutTask: Task<Void, Never> = Task { [weak self] in
                try? await Task.sleep(nanoseconds: UInt64(self?.requestTimeout ?? 30.0 * 1_000_000_000))
                guard let self = self else { return }
                if let entry = self.pendingRequests.removeValue(forKey: requestId) {
                    entry.continuation.resume(throwing: CapsuleWebViewError.requestTimeout)
                }
            }
            
            pendingRequests[requestId] = (continuation, timeoutTask)
            
            webView.evaluateJavaScript("window.postMessage(\(jsonString));") { [weak self] _, error in
                guard let self = self else { return }
                if let error = error {
                    // JS evaluation failed, remove request and cancel timeout
                    let entry = self.pendingRequests.removeValue(forKey: requestId)
                    entry?.timeoutTask?.cancel()
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func loadBridge() {
        let request = URLRequest(url: environment.jsBridgeUrl)
        webView.load(request)
    }
    
    private func initCapsule() {
        // Encode arguments as JSON to avoid injection issues
        let args: [String: String] = [
            "environment": environment.name,
            "apiKey": apiKey,
            "platform": "iOS",
            "package": Self.packageVersion
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: args, options: []),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            // If encoding fails here, set an error
            lastError = CapsuleWebViewError.invalidArguments("Failed to encode init arguments")
            return
        }
        
        let script = """
        window.postMessage({
          messageType: 'Capsule#init',
          arguments: \(jsonString)
        });
        """
        
        webView.evaluateJavaScript(script) { [weak self] _, error in
            if let error = error {
                self?.lastError = error
            }
        }
    }
    
    private func handleCallback(response: [String: Any]) {
        // Validate response
        guard let method = response["method"] as? String else {
            lastError = CapsuleWebViewError.bridgeError("Invalid response: missing 'method'")
            return
        }
        
        // Handle initialization
        if method == "Capsule#init" && response["requestId"] == nil {
            self.isCapsuleInitialized = true
            self.isReady = true
            return
        }
        
        // Expecting requestId for normal method responses
        guard let requestId = response["requestId"] as? String else {
            lastError = CapsuleWebViewError.bridgeError("Invalid response: missing 'requestId' for \(method)")
            return
        }
        
        guard let entry = pendingRequests.removeValue(forKey: requestId) else {
            // Unexpected response for unknown requestId
            lastError = CapsuleWebViewError.bridgeError("Received response for unknown requestId: \(requestId)")
            return
        }
        
        // Cancel timeout
        entry.timeoutTask?.cancel()
        
        // Check for errors
        if let errorMessage = response["error"] as? String {
            entry.continuation.resume(throwing: CapsuleWebViewError.bridgeError(errorMessage))
            return
        }
        
        let responseData = response["responseData"]
        entry.continuation.resume(returning: responseData)
    }
}

@available(iOS 16.4, macOS 10.15, *)
extension CapsuleWebView: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        initCapsule()
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        os_log("WebView failed to load: %@", type: .error, error.localizedDescription)
        initializationError = error
        // We can decide how to handle this: not ready, maybe retry?
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        os_log("WebView provisional load failed: %@", type: .error, error.localizedDescription)
        initializationError = error
    }
}

@available(iOS 16.4, macOS 10.15, *)
extension CapsuleWebView: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "callback" else { return }
        guard let resp = message.body as? [String: Any] else {
            lastError = CapsuleWebViewError.bridgeError("Invalid JS callback payload")
            return
        }
        handleCallback(response: resp)
    }
}

@available(iOS 16.4, macOS 10.15, *)
enum CapsuleWebViewError: Error, CustomStringConvertible {
    case webViewNotReady
    case invalidArguments(String)
    case requestTimeout
    case bridgeError(String)
    
    var description: String {
        switch self {
        case .webViewNotReady:
            return "WebView is not ready to accept requests."
        case .invalidArguments(let msg):
            return "Invalid arguments: \(msg)"
        case .requestTimeout:
            return "The request timed out."
        case .bridgeError(let msg):
            return "Bridge error: \(msg)"
        }
    }
}

@available(iOS 16.4, macOS 10.15, *)
private class LeakAvoider: NSObject, WKScriptMessageHandler {
    weak var delegate: WKScriptMessageHandler?
    init(delegate: WKScriptMessageHandler?) { self.delegate = delegate }
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        delegate?.userContentController(userContentController, didReceive: message)
    }
}

@available(iOS 16.4, macOS 10.15, *)
struct AnyEncodable: Encodable {
    private let encodeFunc: (Encoder) throws -> Void
    init<T: Encodable>(_ value: T) {
        encodeFunc = { encoder in
            try value.encode(to: encoder)
        }
    }
    func encode(to encoder: Encoder) throws {
        try encodeFunc(encoder)
    }
}
