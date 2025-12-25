//
//  APIServicing.swift
//  financial_app
//
//  Created by Heelin Mistry on 2025/12/25.
//

import Combine

protocol APIServicing {
    func request<T: Decodable>(endpoint: APIEndpoint) -> AnyPublisher<T, APIError>
}

// Update APIService.swift to conform to this protocol
extension APIService: APIServicing {}
