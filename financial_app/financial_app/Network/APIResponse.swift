//
//  APIResponse.swift
//  financial_app
//
//  Created by Heelin Mistry on 2025/12/24.
//

import Foundation

// T is a placeholder for the specific Codable type for this request (e.g., [Post] or User)
struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let message: String?
    let data: T
    
    // Custom Coding Keys to map JSON keys to struct properties
    private enum CodingKeys: String, CodingKey {
        case success
        case message
        case data
    }
}
