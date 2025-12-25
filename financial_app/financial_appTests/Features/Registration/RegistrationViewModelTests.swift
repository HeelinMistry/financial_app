//
//  RegistrationViewModelTests.swift
//  financial_app
//
//  Created by Heelin Mistry on 2025/12/25.
//

import XCTest
import Combine
@testable import financial_app

@MainActor
final class RegistrationViewModelTests: XCTestCase {
    
    private var sut: RegistrationViewModel! // System Under Test
    private var mockAPIService: MockAPIService!
    private var mockCoordinator: MockCoordinator!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        // 1. Initialize Mocks
        mockAPIService = MockAPIService()
        mockCoordinator = MockCoordinator()
        cancellables = Set<AnyCancellable>()
        
        // 2. Inject Mocks into the ViewModel
        sut = RegistrationViewModel(apiService: mockAPIService, coordinator: mockCoordinator)
    }
    
    override func tearDown() {
        sut = nil
        mockAPIService = nil
        mockCoordinator = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Validation Tests
    
    func test_isRegisterButtonDisabled_WhenUserIsTooShort() {
        sut.user = "abc" // Length 3
        XCTAssertTrue(sut.isRegisterButtonDisabled, "Button should be disabled for short user name.")
    }
    
    func test_isRegisterButtonDisabled_WhenUserIsLongEnough() {
        sut.user = "HeelinMistry" // Length > 6
        XCTAssertFalse(sut.isRegisterButtonDisabled, "Button should be enabled for valid user name.")
    }
    
    // MARK: - API Success Tests
    
    func test_registerUser_OnSuccess() throws {
        // Arrange
        let expectation = XCTestExpectation(description: "API call completes successfully")
        mockAPIService.shouldSucceed = true
        let mockResponse = 123
        mockAPIService.mockData = mockResponse
        sut.user = "TestUser123"
        
        sut.registerUser()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Check state changes
            XCTAssertFalse(self.sut.isLoading, "Loading should be false after success.")
            
            // Check Coordinator calls
            XCTAssertTrue(self.mockCoordinator.dismissedModal, "Modal should be dismissed.")
            XCTAssertTrue(self.mockCoordinator.presentSuccessToastCalled, "Success toast should be presented.")
            XCTAssertEqual(self.mockCoordinator.lastToastMessage, "User created successfully! Please login", "Toast message mismatch.")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - API Failure Tests
    
    func test_registerUser_OnFailure() throws {
        // Arrange
        let expectation = XCTestExpectation(description: "API call completes with failure")
        mockAPIService.shouldSucceed = false // Force failure
        sut.user = "TestUser123"
        
        // Act
        sut.registerUser()
        
        // Assert: Wait for asynchronous pipeline
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Check state changes
            XCTAssertFalse(self.sut.isLoading, "Loading should be false after failure.")
            
            // Check Coordinator calls
            // Note: Per your last code, closeRegistration() is called on failure
            XCTAssertTrue(self.mockCoordinator.dismissedModal, "Modal should be dismissed on failure.")
            XCTAssertTrue(self.mockCoordinator.presentFailureToastCalled, "Failure toast should be presented.")
            XCTAssertEqual(self.mockCoordinator.lastToastMessage, "User not created! Please try again.", "Toast message mismatch.")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
