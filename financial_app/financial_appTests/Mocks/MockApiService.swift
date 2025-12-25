//
//  MockApiService.swift
//  financial_app
//
//  Created by Heelin Mistry on 2025/12/25.
//

import Foundation
import Combine
@testable import financial_app

class MockAPIService: APIServicing {
    
    // Properties to control the test outcome
    var shouldSucceed = true
    var mockData: Decodable?
    var mockError: APIError = .unknown(URLError(.badServerResponse))
    
    // Properties to verify the ViewModel's call
    var lastEndpointCalled: APIEndpoint?
    
    func request<T: Decodable>(endpoint: APIEndpoint) -> AnyPublisher<T, APIError> {
        self.lastEndpointCalled = endpoint
        
        if shouldSucceed, let data = mockData as? T {
            // Test Case 1: Success Path
            return Just(data)
                .setFailureType(to: APIError.self)
                .eraseToAnyPublisher()
        } else {
            // Test Case 2: Failure Path
            return Fail(error: mockError)
                .eraseToAnyPublisher()
        }
    }
}
