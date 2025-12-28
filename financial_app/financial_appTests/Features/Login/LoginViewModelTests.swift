//
//  LoginViewModelTests.swift
//  financial_app
//
//  Created by Heelin Mistry on 2025/12/25.
//

import XCTest
import Combine
@testable import financial_app

@MainActor
class LoginViewModelTests: XCTestCase {
    
    var mockAPIService: MockAPIService!
    var mockCoordinator: MockCoordinator! // A simple mock to track navigation calls
    var sut: LoginViewModel! // System Under Test
    
    private var cancellables: Set<AnyCancellable>!
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        // Initialize dependencies and the SUT before each test
        mockAPIService = MockAPIService()
        mockCoordinator = MockCoordinator()
        sut = LoginViewModel(apiService: mockAPIService, coordinator: mockCoordinator)
        cancellables = Set<AnyCancellable>()
        
        // Set up default successful credentials
        sut.user = "testUser"
        AuthManager.shared.clearToken()
    }
    
    override func tearDown() {
        // Clean up after each test
        mockAPIService = nil
        mockCoordinator = nil
        sut = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Test Cases
    
    func testLogin_Success_SetsAuthTokenAndNavigates() {
        let expectedToken = "TEST_AUTH_TOKEN_12345"
        let mockTokenResponse = TokenResponse(token: expectedToken)
        mockAPIService.mockData = mockTokenResponse
        mockAPIService.shouldSucceed = true
        
        let expectation = XCTestExpectation(description: "Login completed")
        
        // 2. Observe: Wait for loading to become FALSE.
        sut.$isLoading
            .dropFirst()
            .sink { isLoading in
                if !isLoading {
                    // 3. Assert (After pipeline completes)
                    XCTAssertEqual(AuthManager.shared.token, expectedToken, "AuthManager should have the correct token")
                    XCTAssertEqual(self.mockCoordinator.lastDestination, .userAccounts, "Should navigate to main app flow")
                    XCTAssertNil(self.sut.errorMessage, "Error message should be nil on success")
                    
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        sut.login()
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLogin_APIFailure_PresentToastFailureAndClearsLoading() {
        mockAPIService.shouldSucceed = false
        let mockError: APIError = .serverError(statusCode: 401, message: "Unauthorized")
        mockAPIService.mockError = mockError
        
        let expectation = XCTestExpectation(description: "Login failed and error toast set")
        sut.$isLoading
            .dropFirst() // Ignore the initial nil value set in setUp()
            .filter { $0 == false } // 🚨 Wait until isLoading transitions back to FALSE
            .sink { isLoading in
                XCTAssertFalse(isLoading, "Loading should be false after failure.")
                XCTAssertNil(AuthManager.shared.token, "AuthManager token should not be set on failure.")
                XCTAssertNil(self.mockCoordinator.lastDestination, "Should not navigate on failure.")
                XCTAssertTrue(self.mockCoordinator.presentFailureToastCalled, "Should be called")
                
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // 4. Act: Call the method under test
        sut.login()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLoginButton_Disabled_WhenFieldsAreEmpty() {
        sut.user = ""
        XCTAssertTrue(sut.isLoginButtonDisabled, "Button should be disabled when fields are empty")
        sut.user = "user"
        XCTAssertTrue(sut.isLoginButtonDisabled, "Button should be disabled when password is < 6")
        sut.user = "userTest"
        XCTAssertFalse(sut.isLoginButtonDisabled, "Button should be enabled when password >= 6")
    }
    
    func testLogin_Failure_WhenFieldsArePartial() {
        sut.user = "user"
        sut.login()
        XCTAssertFalse(sut.isLoading, "Button should be disabled when password is < 6")
        XCTAssertNil(AuthManager.shared.token, "AuthManager token should not be set on failure.")
        XCTAssertNil(sut.errorMessage, "Error message must be set on failure.")

    }
}
