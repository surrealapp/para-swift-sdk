import SwiftUI
import CapsuleSwift

@main
struct exampleApp: App {
    @StateObject private var capsuleManager: CapsuleManager
    @StateObject private var appRootManager = AppRootManager()
    
init() {
    let environmentString = Bundle.main.object(forInfoDictionaryKey: "CAPSULE_ENVIRONMENT") as? String ?? "beta"
    
    let environment: CapsuleEnvironment = environmentString == "sandbox" ? .sandbox : .beta
    
    let apiKey = Bundle.main.object(forInfoDictionaryKey: "CAPSULE_API_KEY") as! String
    
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

