//
//  UserAccountsViewModelTests.swift
//  financial_app
//
//  Created by Heelin Mistry on 2025/12/25.
//

import XCTest
import Combine
@testable import financial_app

@MainActor
class UserAccountsViewModelTests: XCTestCase {
    
    var mockAPIService: APIServicing!
    var sut: UserAccountsViewModel!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockAPIService = MockAPIService()
        sut = UserAccountsViewModel(apiService: mockAPIService, coordinator: nil)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        // Clean up
        mockAPIService = nil
        sut = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Test Cases
    
    func testInitialState() {
        XCTAssertTrue(sut.accounts.isEmpty, "Accounts should be empty initially")
        XCTAssertFalse(sut.isLoading, "Loading should be false initially")
        XCTAssertNil(sut.errorMessage, "Error message should be nil initially")
    }
    
    func testFetchUserAccounts_Success_UpdatesAccountsAndClearsLoading() {
        let expectedAccounts: [Account] = [
            Account(id: 1,
                    ownerId: "1",
                    name: "Test",
                    type: "SAVING",
                    monthlyHistory: [
                        MonthlyHistory(
                            monthKey: "2025-11",
                            openingBalance: 100.00,
                            contribution: 25.00,
                            closingBalance: 200.0,
                            exchangeRate: 1.0
                        )
                    ]),
            Account(id: 1,
                    ownerId: "2",
                    name: "User",
                    type: "LOAN",
                    monthlyHistory: [
                        MonthlyHistory(
                            monthKey: "2025-11",
                            openingBalance: 200.00,
                            contribution: 50.00,
                            closingBalance: 150.0,
                            exchangeRate: 1.0
                        )
                    ])
        ]
        mockAPIService.mockData = expectedAccounts
        mockAPIService.shouldSucceed = true
        
        let expectation = XCTestExpectation(description: "Accounts received and state updated")
        
        // 2. Observe: Wait for the isLoading state to transition back to false.
        sut.$isLoading
            .dropFirst() // Ignore the state change from false -> true
            .sink { isLoading in
                if !isLoading {
                    // 3. Assert (After pipeline completes)
                    XCTAssertFalse(isLoading, "Loading must be false after success")
                    XCTAssertNil(self.sut.errorMessage, "Error message must be nil after success")
                    
                    // 🚨 Crucial: Check the accounts array content
                    XCTAssertEqual(self.sut.accounts.count, 2, "Should receive 2 accounts")
                    XCTAssertEqual(self.sut.accounts, expectedAccounts, "Received accounts should match mock data")
                    
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sut.fetchUserAccounts()
        XCTAssertTrue(sut.isLoading, "Loading should be true immediately after call")
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchUserAccounts_APIFailure_SetsErrorMessageAndClearsLoading() {
        // 1. Arrange: Mock the API failure response
        let mockError: APIError = .serverError(statusCode: 500, message: "Server Down")
        mockAPIService.shouldSucceed = false
        mockAPIService.mockError = mockError
        
        // Use the error message itself for a robust observation
        let expectation = XCTestExpectation(description: "Error message set after failure")
        
        // 2. Observe: Wait until the errorMessage is no longer nil.
        sut.$errorMessage
            .dropFirst()
            .compactMap { $0 } // Only fires when the value becomes non-nil
            .sink { errorMessage in
                
                // 3. Assert (After pipeline delivers the error)
                XCTAssertFalse(self.sut.isLoading, "Loading should be false after failure")\
                XCTAssertEqual(errorMessage, mockError.localizedDescription, "Error message must match the mock error description")
                XCTAssertTrue(self.sut.accounts.isEmpty, "Accounts array must remain empty on failure")
                
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.fetchUserAccounts()
        XCTAssertTrue(sut.isLoading, "Loading should be true immediately after call")
        wait(for: [expectation], timeout: 1.0)
    }
}
