//
//  APIError.swift
//  financial_app
//
//  Created by Heelin Mistry on 2025/12/24.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case serverError(statusCode: Int, message: String)
    case decodingError(Error)
    case apiFailure(message: String) // For when "success" is false in the response
    case unknown(Error)
    case noContentSuccess

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL provided was invalid."
        case .serverError(let code, let message):
            return "Server responded with status code \(code). Details: \(message)"
        case .decodingError(let error):
            return "Failed to decode the server response. \(error.localizedDescription)"
        case .apiFailure(let message):
            return "API call failed (success: false). Message: \(message)"
        case .unknown(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        case .noContentSuccess:
            return "No Content with success: true"
        }
    }
}
