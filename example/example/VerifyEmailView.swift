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
    
    let email: String
    
    @State private var code = ""

    
    @Environment(\.authorizationController) private var authorizationController
        
    var body: some View {
        VStack {
            TextField("Code", text: $code)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button("Verify") {
                Task.init {
                    let biometricsId = try! await capsule.verify(verificationCode: code)
                    try! await capsule.generatePasskey(email: email, biometricsId: biometricsId, authorizationController: authorizationController)
                    try! await capsule.createWallet(skipDistributable: false)
                }
            }
            .buttonStyle(.bordered)
        }.padding()
    }
}

#Preview {
    VerifyEmailView(email: "")
}
