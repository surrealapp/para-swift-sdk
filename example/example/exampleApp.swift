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
    @StateObject var capsuleManager = CapsuleManager(environment: defaultDevEnv, apiKey: "4f1d69a07c0fdc0bd16472a0780b770c")

    var body: some Scene {
        WindowGroup {
            UserAuthView()
                .environmentObject(capsuleManager)
        }
    }
}
