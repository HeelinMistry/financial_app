//
//  TokenResponse.swift
//  financial_app
//
//  Created by Heelin Mistry on 2025/12/24.
//

// Data structure for the body of the POST request
struct LoginData: Encodable, Sendable {
    let name: String
}

struct TokenResponse: Decodable, Sendable {
    let token: String  // Captures the 'token' string
}
