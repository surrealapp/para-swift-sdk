import SwiftUI
import ParaSwift

@main
struct exampleApp: App {
    @StateObject private var paraManager: ParaManager
    @StateObject private var appRootManager = AppRootManager()
    
init() {
    let environmentString = Bundle.main.object(forInfoDictionaryKey: "CAPSULE_ENVIRONMENT") as? String ?? "beta"
    
    let environment: ParaEnvironment = environmentString == "sandbox" ? .sandbox : .beta
    
    let apiKey = Bundle.main.object(forInfoDictionaryKey: "CAPSULE_API_KEY") as! String
    
    _paraManager = StateObject(wrappedValue: ParaManager(environment: environment, apiKey: apiKey))
}
    
    var body: some Scene {
        WindowGroup {
            switch appRootManager.currentRoot {
            case .authentication:
                UserAuthView()
                    .environmentObject(paraManager)
                    .environmentObject(appRootManager)
            case .home:
                WalletView()
                    .environmentObject(paraManager)
                    .environmentObject(appRootManager)
            }
        }
    }
}

