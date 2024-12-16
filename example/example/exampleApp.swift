//
//  exampleApp.swift
//  example
//
//  Created by Brian Corbin on 6/18/24.
//

import SwiftUI
import CapsuleSwift

@main
struct exampleApp: App {
    @StateObject private var capsuleManager = CapsuleManager(environment: .sandbox, apiKey: "8ee2d015fbc6062a6e30bdc472f2946c")
    @StateObject private var appRootManager = AppRootManager()
    
    var body: some Scene {
        WindowGroup {
            switch appRootManager.currentRoot {
            case .authentication:
                UserAuthView().environmentObject(capsuleManager).environmentObject(appRootManager)
            case .home:
                WalletView().environmentObject(capsuleManager).environmentObject(appRootManager)
            }
        }
    }
}
