//
//  AccountFormViewModelTests.swift
//  financial_app
//
//  Created by Heelin Mistry on 2025/12/31.
//

import XCTest
import Combine
@testable import financial_app

@MainActor
class AccountFormViewModelTests: XCTestCase {
    
    var mockAPIService: MockAPIService!
    var mockCoordinator: MockCoordinator! // A simple mock to track navigation calls
    var sut: AccountFormViewModel!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockAPIService = MockAPIService()
        mockCoordinator = MockCoordinator()
        sut = AccountFormViewModel(apiService: mockAPIService, coordinator: mockCoordinator)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        // Clean up
        mockAPIService = nil
        mockCoordinator = nil
        sut = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Test Cases
    
    func testInitialState() {
        XCTAssertFalse(sut.isLoading, "Loading should be false initially")
        XCTAssertTrue(sut.isSaveButtonDisabled, "Initially save disabled")
    }
    
    func testCloseAddAccountsForm() {
        sut.closeAccountsForm()
        XCTAssertTrue(mockCoordinator.dismissedSheet, "Should show the add account sheet")

    }
    
    func testAddAccounts_Success_SendsRefresh() {
        mockAPIService.mockData = 123456
        mockAPIService.shouldSucceed = true
        
        let expectation = XCTestExpectation(description: "Accounts received and state updated")
        
        // 2. Observe: Wait for the isLoading state to transition back to false.
        sut.$isLoading
            .dropFirst() // Ignore the state change from false -> true
            .sink { isLoading in
                if !isLoading {
                    // 3. Assert (After pipeline completes)
                    XCTAssertFalse(isLoading, "Loading must be false after success")
                    XCTAssertTrue(self.mockCoordinator.presentSuccessToastCalled, "Show toast should have been called")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sut.name = "test account"
        sut.addAccount()
        XCTAssertTrue(sut.isLoading, "Loading should be true immediately after call")
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testAddAccounts_Failure_ShowToast() {
        mockAPIService.shouldSucceed = false
        
        let expectation = XCTestExpectation(description: "Accounts received and state updated")
        
        // 2. Observe: Wait for the isLoading state to transition back to false.
        sut.$isLoading
            .dropFirst() // Ignore the state change from false -> true
            .sink { isLoading in
                if !isLoading {
                    // 3. Assert (After pipeline completes)
                    XCTAssertFalse(isLoading, "Loading must be false after success")
                    XCTAssertTrue(self.mockCoordinator.presentFailureToastCalled, "Show toast should have been called")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sut.name = "test account"
        sut.addAccount()
        XCTAssertTrue(sut.isLoading, "Loading should be true immediately after call")
        wait(for: [expectation], timeout: 1.0)
    }
}
