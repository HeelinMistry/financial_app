//
//  APIService.swift
//  financial_app
//
//  Created by Heelin Mistry on 2025/12/24.
//

import Foundation
import Combine

class APIService {
    
    static let shared = APIService()
    private init() {}
    
    // MARK: - Debug Logger
    private func debugLog(request: URLRequest?, data: Data?, response: URLResponse?, error: Error?, stage: String) {
        print("\n================== API DEBUG LOG (\(stage)) ==================")
        
        if let request = request {
            print("➡️ Request URL: \(request.url?.absoluteString ?? "N/A")")
            print("➡️ Method: \(request.httpMethod ?? "N/A")")
            
            if let headers = request.allHTTPHeaderFields {
                print("➡️ Headers: \(headers)")
            }
            
            if let bodyData = request.httpBody,
               let bodyString = String(data: bodyData, encoding: .utf8) {
                print("➡️ Body: \(bodyString)")
            }
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            print("⬅️ Response Status: \(httpResponse.statusCode)")
        }
        
        if let data = data,
           let dataString = String(data: data, encoding: .utf8) {
            print("⬅️ Raw Response Data:")
            // Print up to 1000 characters to avoid flooding the console
            print(dataString.prefix(1000) + (dataString.count > 1000 ? "..." : ""))
        }
        
        if let error = error {
            print("❌ Error: \(error.localizedDescription)")
            if let apiError = error as? APIError {
                 print("❌ APIError Type: \(apiError)")
            }
        }
        
        print("==========================================================\n")
    }
    
    // MARK: - Core Request Method
    
    // Returns a Combine Publisher that emits the decoded T (the actual data payload)
    func request<T: Decodable>(endpoint: APIEndpoint) -> AnyPublisher<T, APIError> {
        
        let request: URLRequest
        do {
            request = try endpoint.urlRequest()
        } catch {
            // Immediately fail if URL creation fails
            return Fail(error: error as? APIError ?? APIError.unknown(error)).eraseToAnyPublisher()
        }
        
        // 2. Execute the request using URLSession
        return URLSession.shared.dataTaskPublisher(for: request)
            
            // 3. Map to Data or handle generic transport errors
            .tryMap { data, response in
                self.debugLog(request: request, data: data, response: response, error: nil, stage: "Response Received")
                // Check for HTTP status codes (4xx/5xx errors)
                if let httpResponse = response as? HTTPURLResponse, !(200..<300).contains(httpResponse.statusCode) {
                    let message = String(data: data, encoding: .utf8) ?? "No message"
                    throw APIError.serverError(statusCode: httpResponse.statusCode, message: message)
                }
                return data
            }
            
            // 4. Decode the data into the generic APIResponse wrapper
            .decode(type: APIResponse<T>.self, decoder: JSONDecoder())
            .mapError { error -> APIError in
                // Map decoding errors to our custom APIError type
                if let decodingError = error as? DecodingError {
                    return APIError.decodingError(decodingError)
                }
                if let apiError = error as? APIError {
                    return apiError
                }
                return APIError.unknown(error)
            }
            
            // 5. Check the "success" flag from the APIResponse
            .flatMap { apiResponse -> AnyPublisher<T, APIError> in
                if apiResponse.success {
                    // Success! Return the nested data
                    return Just(apiResponse.data)
                        .setFailureType(to: APIError.self) // Set failure type for consistency
                        .eraseToAnyPublisher()
                } else {
                    // API call failed even though HTTP status was 2xx (e.g., login failed)
                    return Fail(error: APIError.apiFailure(message: apiResponse.message ?? ""))
                        .eraseToAnyPublisher()
                }
            }
            
            .eraseToAnyPublisher()
    }
}
