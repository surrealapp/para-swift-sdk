//
//  EmailAuthView.swift
//  example
//
//  Created by Brian Corbin on 12/13/24.
//

import SwiftUI
import CapsuleSwift

struct EmailAuthView: View {
    @EnvironmentObject var capsuleManager: CapsuleManager
    @EnvironmentObject var appRootManager: AppRootManager

    @State private var email = ""
    
    @State private var showWalletView = false
    @State private var newApiKey: String = ""
    
    @State private var showingSetApiKeyAlert = false
        
    @Environment(\.authorizationController) private var authorizationController
    var body: some View {
        VStack {
            TextField("Email Address", text: $email)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
            HStack {
                Button {
                    Task.init {
                        print("checking if user exists...")
                        let userExists = try await capsuleManager.checkIfUserExists(email: email)
                        print(userExists)
                        if userExists {
                            return
                        }
                        
                        try await capsuleManager.createUser(email: email)
                    }
                } label: {
                    Text("Sign Up").frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            HStack {
                Rectangle().frame(height: 1)
                Text("Or")
                Rectangle().frame(height: 1)
            }.padding(.vertical)
            
            Button {
                Task.init {
                    try await capsuleManager.login(authorizationController: authorizationController)
                    appRootManager.currentRoot = .home
                }
            } label: {
                Text("Log In with Passkey")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .navigationTitle("Email Authentication")
    }
}

#Preview {
    EmailAuthView()
}
