import SwiftUI
import CapsuleSwift

struct VerifyPhoneView: View {
    @EnvironmentObject var capsule: CapsuleManager
    @EnvironmentObject var appRootManager: AppRootManager
    
    let phoneNumber: String
    let countryCode: String
    
    @State private var code = ""
    @State private var isLoading = false
    @State private var loadingStateText = ""
    @State private var errorMessage: String?
    
    @Environment(\.authorizationController) private var authorizationController
    
    var body: some View {
        VStack(spacing: 20) {
            Text("A verification code was sent to your phone number. Enter it below to verify.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            TextField("Verification Code", text: $code)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .disabled(isLoading)
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            if isLoading {
                if !loadingStateText.isEmpty {
                    Text(loadingStateText)
                        .foregroundColor(.secondary)
                }
                ProgressView()
            }
            
            Button {
                guard !code.isEmpty else {
                    errorMessage = "Please enter the verification code."
                    return
                }
                isLoading = true
                errorMessage = nil
                loadingStateText = "Verifying..."
                Task {
                    do {
                        let biometricsId = try await capsule.verifyByPhone(verificationCode: code)
                        loadingStateText = "Generating Passkey..."
                        try await capsule.generatePasskey(identifier: "\(countryCode)\(phoneNumber)", biometricsId: biometricsId, authorizationController: authorizationController)
                        loadingStateText = "Creating Wallet..."
                        try await capsule.createWallet(skipDistributable: false)
                        isLoading = false
                        appRootManager.currentRoot = .home
                    } catch {
                        isLoading = false
                        errorMessage = "Verification failed: \(error.localizedDescription)"
                    }
                }
            } label: {
                Group {
                    if isLoading {
                        Text("Working...")
                    } else {
                        Text("Verify")
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading || code.isEmpty)
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Verify Phone")
    }
}

