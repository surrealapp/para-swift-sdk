import SwiftUI
import CapsuleSwift

@main
struct exampleApp: App {
    @StateObject private var capsuleManager: CapsuleManager
    @StateObject private var appRootManager = AppRootManager()
    
    init() {
        let environmentString = ProcessInfo.processInfo.environment["ENVIRONMENT"] ?? "beta"
        
        let environment: CapsuleEnvironment = environmentString == "sandbox" ? .sandbox : .beta
        
        let sandboxApiKey = ProcessInfo.processInfo.environment["CAPSULE_SANDBOX_API_KEY"]
        let betaApiKey = ProcessInfo.processInfo.environment["CAPSULE_BETA_API_KEY"]
        
        let apiKey: String
        if environment == .sandbox {
            guard let key = sandboxApiKey, !key.isEmpty else {
                fatalError("CAPSULE_SANDBOX_API_KEY not found or empty in environment variables.")
            }
            apiKey = key
        } else {
            guard let key = betaApiKey, !key.isEmpty else {
                fatalError("CAPSULE_BETA_API_KEY not found or empty in environment variables.")
            }
            apiKey = key
        }
        
        _capsuleManager = StateObject(wrappedValue: CapsuleManager(environment: environment, apiKey: apiKey))
    }
    
    var body: some Scene {
        WindowGroup {
            switch appRootManager.currentRoot {
            case .authentication:
                UserAuthView()
                    .environmentObject(capsuleManager)
                    .environmentObject(appRootManager)
            case .home:
                WalletView()
                    .environmentObject(capsuleManager)
                    .environmentObject(appRootManager)
            }
        }
    }
}

