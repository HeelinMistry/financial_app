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

// Models/TokenResponse.swift (UPDATED)

// 1. Represents the 'user' object inside the 'data'
struct UserInfo: Decodable, Sendable {
    let id: Int // Or String, depending on your server
}

// 2. Represents the entire 'data' payload from the APIResponse
struct TokenResponse: Decodable, Sendable {
    let user: UserInfo // Captures the nested 'user' dictionary
    let token: String  // Captures the 'token' string

    // NOTE: If your server uses a different key for token, like 'access_token',
    // you must use CodingKeys here. Based on your log, it seems to be 'token'.
}
