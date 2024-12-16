//
//  VerifyEmailView.swift
//  swift-example
//
//  Created by Brian Corbin on 6/4/24.
//

import SwiftUI
import CapsuleSwift

struct VerifyEmailView: View {
    
    @EnvironmentObject var capsule: CapsuleManager
    @EnvironmentObject var appRootManager: AppRootManager
    
    let email: String
    
    @State private var code = ""
    @State private var isLoading = false
    @State private var loadingStateText = ""
    
    @Environment(\.authorizationController) private var authorizationController
        
    var body: some View {
        VStack {
            TextField("Code", text: $code)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disabled(isLoading)
            Button {
                Task.init {
                    isLoading = true
                    loadingStateText = "Verifying"
                    let biometricsId = try! await capsule.verify(verificationCode: code)
                    loadingStateText = "Generating Passkey"
                    try! await capsule.generatePasskey(email: email, biometricsId: biometricsId, authorizationController: authorizationController)
                    loadingStateText = "Creating Wallet"
                    try! await capsule.createWallet(skipDistributable: false)
                    appRootManager.currentRoot = .home
                }
            } label: {
                Group {
                    if (isLoading) {
                        HStack {
                            Text(loadingStateText)
                            ProgressView()
                        }
                    } else {
                        Text("Verify")
                    }
                }.frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(isLoading)
        }.padding()
    }
}

#Preview {
    VerifyEmailView(email: "")
}
