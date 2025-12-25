//
//  AuthManager.swift
//  financial_app
//
//  Created by Heelin Mistry on 2025/12/24.
//

import Foundation

class AuthManager {
    // MARK: - Singleton
    static let shared = AuthManager()
    
    // Private initializer prevents external instantiation
    private init() {}
    
    // MARK: - Constants
    private let tokenKey = "authTokenKey"
    
    // MARK: - Token Storage & Retrieval
    
    /**
     Retrieves the stored authentication token.
     Note: In a production app, use KeychainSwift or a similar library here
     instead of UserDefaults for security.
    */
    var token: String? {
        // Retrieve token from UserDefaults (Placeholder)
        return UserDefaults.standard.string(forKey: tokenKey)
    }

    /**
     Checks if a token is currently stored.
    */
    var isAuthenticated: Bool {
        return token != nil
    }
    
    /**
     Sets the authentication token after a successful login.
    */
    func setToken(_ token: String) {
        // Store token in UserDefaults (Placeholder)
        UserDefaults.standard.set(token, forKey: tokenKey)
        print("AuthManager: Token set successfully.")
    }
    
    /**
     Clears the token during logout.
    */
    func clearToken() {
        // Remove token from UserDefaults (Placeholder)
        UserDefaults.standard.removeObject(forKey: tokenKey)
        print("AuthManager: Token cleared.")
    }
}
