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
    case login(_ data: LoginData)
    case register(_ data: LoginData)
    case userAccounts
    case createAccount(_ data: AccountDetails)
    case deleteAccount(_ data: Account)
    case updateAccount(accountId: Int, requestData: MonthlyHistory)
    
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
        case .createAccount:
            return "accounts/create"
        case .deleteAccount(let data):
            return "accounts/\(data.id)"
        case .updateAccount:
            return "accounts/history"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .login,
                .register,
                .createAccount:
            return .post
        case .userAccounts:
            return .get
        case .deleteAccount:
            return .delete
        case .updateAccount:
            return .put
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
            case .createAccount(let data):
                let payload: [String: Any] = [
                    "name": data.name,
                    "type": data.type.rawValue
                ]
                return try? JSONSerialization.data(withJSONObject: payload, options: [])
                
            default:
                return nil
            }
            
        case .put, .delete:
            switch self {
            case .updateAccount(let id, let data):
                let payload: [String: Any] = [
                    "accountId": id,
                    "monthKey": data.monthKey,
                    "openingBalance": data.openingBalance ?? 0.0,
                    "contribution": data.contribution ?? 0.0,
                    "closingBalance": data.closingBalance ?? 0.0,
                    "exchangeRate": data.exchangeRate,
                    "interestRate": data.interestRate as Any,
                    "termsLeft": data.termsLeft as Any
                ]
                return try? JSONSerialization.data(withJSONObject: payload, options: [])
            default:
                return nil
            }
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
