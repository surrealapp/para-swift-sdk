//
//  AppRootManager.swift
//  example
//
//  Created by Brian Corbin on 12/13/24.
//

import Foundation

final class AppRootManager: ObservableObject {
    
    @Published var currentRoot: eAppRoots = .authentication
    
    enum eAppRoots {
        case authentication
        case home
    }
}
