# Capsule Swift SDK

[![Swift](https://img.shields.io/badge/Swift-5.7+-orange?style=flat-square)](https://img.shields.io/badge/Swift-5.7+-Orange?style=flat-square)
[![iOS](https://img.shields.io/badge/iOS-16.4+-yellowgreen?style=flat-square)](https://img.shields.io/badge/iOS-16.4+-Green?style=flat-square)
[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)

## Installation

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding CapsuleSwift as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift` or the Package list in Xcode.

```swift
dependencies: [
    .package(url: "https://github.com/capsule-org/swift-sdk.git", .upToNextMajor(from: "0.0.1"))
]
```

Normally you'll want to depend on the `Alamofire` target:

```swift
.product(name: "CapsuleSwift", package: "CapsuleSwift")
```

## Using Capsule Swift

### Introduction

CapsuleSwift provides an interface to Capsule services from within iOS applications using SwiftUI (Support for UIKit comming soon).

### Configuring

To configure the capsule instance, you will need to create an instance of the capsule object as well as the globally available authorizationController environment object. This will be needed in several functions later on. If you need an API Key, please reach out to the Capsule Team.

You will also need to add an instance of the CapsuleWebView to your view passing in the instance of Capsule that we just created, and set it to hidden so that it doesn't appear on screen. It is recommended to use a ZStack and set this as the topmost view, which will hide it behind all other views that render on the screen.

```swift
struct UserAuthView: View {
    @StateObject var capsule = CapsuleSwift.Capsule(environment: CapsuleEnvironment.beta(jsBridgeUrl: nil), apiKey: "<YOUR_API_KEY>")
    @Environment(\.authorizationController) private var authorizationController
        
    var body: some View {
        ZStack {
            CapsuleWebView(viewModel: capsule).hidden()
...
```

### Creating a User

To create a user, you should first check in the provided email address exists, and if it does not then create it

```swift
Button("Sign Up") {
    Task.init {
        let userExists = try! await capsule.checkIfUserExists(email: email)
        
        if userExists {
            return
        }
        
        try! await capsule.createUser(email: email)
        ...
    }
}
```

Upon success, the user should receive an email with a 6 digit verification pin. Call the verify function with the verification code acquired from this step. This will return a biometricsId which will be necessary to pass to the next function, generatePasskey.

Generate passkey takes in the authorizationController that was set up earlier. This is necessary to be able to allow the application to present the Passkey modals for creating and selecting a Passkey.

After generating the passkey, the last step is to create a wallet.

```swift
Button("Verify") {
    Task.init {
        let biometricsId = try! await capsule.verify(verificationCode: code)
        try! await capsule.generatePasskey(email: email, biometricsId: biometricsId, authorizationController: authorizationController)
        try! await capsule.createWallet(skipDistributable: false)
    }
}
```

After the wallet has been created, it will be set in the Capsule object as a Published var.

### Signing a Message

To sign a message, all you need to do is pass in the id of the wallet you would like to use which can be obtained from the capsule.wallet property, and the text that you would like to sign. This will produce a messageSignature.

```swift
Button("Sign Message") {
    Task.init {
        let messageSignature = try! await capsule.signMessage(walletId: wallet.id, message: "Some message to sign")
        ...
    }
}
```
