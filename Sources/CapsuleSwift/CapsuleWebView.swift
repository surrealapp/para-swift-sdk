//
//  SwiftUIView.swift
//  
//
//  Created by Joe Blau on 6/25/24.
//

import SwiftUI
import WebKit


/// A UIViewRepresentable that allows access to functions of the [JavaScript Bridge](https://github.com/capsule-org/web-sdk/blob/main/sites/bridge/src/index.ts)
///
/// > Important: This must be added to your view to enable the Capsule instance to access the
/// > [JavaScript Bridge](https://github.com/capsule-org/web-sdk/blob/main/sites/bridge/src/index.ts),
/// > and should be hidden
///
/// ```swift
/// ZStack {
///     CapsuleWebView(viewModel: capsule).hidden()
///     ...
/// ```
@available(iOS 16.4, *)
public struct CapsuleWebView: UIViewRepresentable {
    
    /// An instance of the Capsule class
    public var capsuleManager: CapsuleManager
    /**
     Initializes a new CapsuleWebView with the provided Capsule instance
     
     - Parameters:
     - capsule: An instance of the Capsule class
     
     - Returns: A new instance of the CapsuleWebView struct
     */
    public init(capsuleManager: CapsuleManager) {
        self.capsuleManager = capsuleManager
    }
    
    public func makeUIView(context: Context) -> WKWebView {
        capsuleManager.webView
    }
    
    public func updateUIView(_ uiView: WKWebView, context: Context) {}
}

//#Preview {
//    CapsuleWebView()
//}
