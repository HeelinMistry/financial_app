//
//  APIEndpoints.swift
//  financial_app
//
//  Created by Heelin Mistry on 2025/12/24.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum APIEndpoint {
    case login(data: LoginData)
    case register(data: LoginData)
    case userAccounts
    
    // Base URL for your server
    private var baseURL: String { "http://localhost:3000/api/" }
    
    // MARK: - Request Components
    
    var path: String {
        switch self {
        case .login:
            return "users/login"
        case .register:
            return "users/register"
        case .userAccounts:
            return "accounts"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .login,
                .register:
            return .post
        case .userAccounts:
            return .get
        }
    }
    
    var body: Data? {
        switch self.method {
        case .get:
            return nil
            
        case .post:
            switch self {
            case .login(let data):
                let payload: [String: Any] = ["name": data.name]
                return try? JSONSerialization.data(withJSONObject: payload, options: [])
            case .register(let data):
                let payload: [String: Any] = ["name": data.name]
                return try? JSONSerialization.data(withJSONObject: payload, options: [])
            default:
                return nil
            }
            
        case .put, .delete:
            return nil // Placeholder, update as needed for specific endpoints
        }
    }
    
    // MARK: - Final URLRequest
    
    func urlRequest() throws -> URLRequest {
        guard let url = URL(string: baseURL + path) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = AuthManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = body
        }
        
        return request
    }
}
