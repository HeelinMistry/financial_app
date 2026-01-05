//
//  AccountSummaryRowViewModelTests.swift
//  financial_app
//
//  Created by Heelin Mistry on 2025/12/31.
//

import XCTest
import Combine
@testable import financial_app

@MainActor
class AccountSummaryRowViewModelTests: XCTestCase {
    
    var mockAPIService: MockAPIService!
    var mockCoordinator: MockCoordinator! // A simple mock to track navigation calls
    var sut: AccountSummaryRowViewModel!
    private var cancellables: Set<AnyCancellable>!
    
    let mockAccount: Account = .init(id: 1, ownerId: 123, name: "Tester", type: .SAVING, monthlyHistory: [])
    
    override func setUp() {
        super.setUp()
        mockAPIService = MockAPIService()
        mockCoordinator = MockCoordinator()
        sut = AccountSummaryRowViewModel(account: mockAccount, apiService: mockAPIService, coordinator: mockCoordinator)
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
        XCTAssertFalse(sut.isDeleting, "Deleting should be false initially")
    }
    
    func testEditAccountForm() {
        sut.editAccount()
        XCTAssertEqual(mockCoordinator.lastDestination, Destination.presentSheet(destination: .updateAccountHistory(account: mockAccount)), "Should show the add account sheet")

    }
}
