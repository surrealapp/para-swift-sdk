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
    @StateObject private var capsuleManager = CapsuleManager(environment: .beta, apiKey: "9b667f53214d63add622567c51122511")
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
