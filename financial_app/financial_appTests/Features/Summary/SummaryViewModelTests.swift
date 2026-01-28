//
//  SummaryViewModelTests.swift
//  financial_app
//
//  Created by Heelin Mistry on 2026/01/28.
//

import XCTest
import Combine
@testable import financial_app

@MainActor
class SummaryViewModelTests: XCTestCase {
    
    var mockAPIService: MockAPIService!
    var mockCoordinator: MockCoordinator! // A simple mock to track navigation calls
    var repo: UserAccountsRepository!
    var sut: SummaryViewModel!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockAPIService = MockAPIService()
        mockCoordinator = MockCoordinator()
        repo = DefaultUserAccountsRepository(apiService: mockAPIService)
        sut = SummaryViewModel(repository: repo, coordinator: mockCoordinator)
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
        XCTAssertTrue(sut.accounts.isEmpty, "Accounts should be empty initially")
        XCTAssertFalse(sut.isLoading, "Loading should be false initially")
    }
    
    func testFetchUserAccounts_Success_UpdatesAccountsAndClearsLoading() {
        let expectedAccounts: [Account] = [
            Account(id: 1,
                    ownerId: 1,
                    name: "Test",
                    type: .SAVING,
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
                    ownerId: 2,
                    name: "User",
                    type: .LOAN,
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
    
    func testFetchUserAccounts_APIFailure_PresentsToastFailureAndClearsLoading() {
        // 1. Arrange: Mock the API failure response
        let mockError: APIError = .serverError(statusCode: 500, message: "Server Down")
        mockAPIService.shouldSucceed = false
        mockAPIService.mockError = mockError
        
        // Use the error message itself for a robust observation
        let expectation = XCTestExpectation(description: "Error message set after failure")
        
        // 2. Observe: Wait until the errorMessage is no longer nil.
        sut.$isLoading
            .dropFirst()
            .filter { $0 == false } // 🚨 Wait until isLoading transitions back to FALSE
            .sink { isLoading in
                XCTAssertFalse(isLoading, "Loading should be false after failure")
                XCTAssertTrue(self.sut.accounts.isEmpty, "Accounts array must remain empty on failure")
                XCTAssertTrue(self.mockCoordinator.presentFailureToastCalled, "Should be called")

                expectation.fulfill()
            }
            .store(in: &cancellables)
        sut.fetchUserAccounts(forceRefresh: true)
        XCTAssertTrue(sut.isLoading, "Loading should be true immediately after call")
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchUserAccounts_RefreshAccounts_Trgiggered() {
        let expectedAccounts: [Account] = [
            Account(id: 1,
                    ownerId: 1,
                    name: "Test",
                    type: .SAVING,
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
                    ownerId: 2,
                    name: "User",
                    type: .LOAN,
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
                    XCTAssertEqual(self.sut.accounts.count, 2, "Should receive 2 accounts")
                    XCTAssertEqual(self.sut.accounts, expectedAccounts, "Received accounts should match mock data")

                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        mockCoordinator.accountDidChange.send(())
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFilterForSelectedMonth() {
        // Arrange: two accounts, two months each, with different exchange rates
        // Account A: SAVING
        // - 2025-10: OB 100, CO 10, CB 120, ER 1.0
        // - 2025-11: OB 120, CO 15, CB 150, ER 1.1
        // Account B: LOAN
        // - 2025-10: OB 200, CO 20, CB 180, ER 1.2
        // - 2025-11: OB 180, CO 25, CB 160, ER 1.0
        let accounts: [Account] = [
            Account(
                id: 101,
                ownerId: 1,
                name: "Savings",
                type: .SAVING,
                monthlyHistory: [
                    MonthlyHistory(monthKey: "2025-10", openingBalance: 100.0, contribution: 10.0, closingBalance: 120.0, exchangeRate: 1.0),
                    MonthlyHistory(monthKey: "2025-11", openingBalance: 120.0, contribution: 15.0, closingBalance: 150.0, exchangeRate: 1.1)
                ]
            ),
            Account(
                id: 202,
                ownerId: 1,
                name: "Loan",
                type: .LOAN,
                monthlyHistory: [
                    MonthlyHistory(monthKey: "2025-10", openingBalance: 200.0, contribution: 20.0, closingBalance: 180.0, exchangeRate: 1.2),
                    MonthlyHistory(monthKey: "2025-11", openingBalance: 180.0, contribution: 25.0, closingBalance: 160.0, exchangeRate: 1.0)
                ]
            )
        ]
        mockAPIService.mockData = accounts
        mockAPIService.shouldSucceed = true
        
        // Expectation: wait until accounts are fetched and months generated
        let fetchExpectation = XCTestExpectation(description: "Fetched accounts and generated months")
        
        sut.$availableMonths
            .dropFirst()
            .sink { months in
                if !months.isEmpty {
                    fetchExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sut.fetchUserAccounts(forceRefresh: true)
        wait(for: [fetchExpectation], timeout: 1.0)
        
        // Pick the month "2025-11"
        guard let targetMonth = sut.availableMonths.first(where: { $0.monthKey == "2025-11" }) else {
            return XCTFail("Expected month '2025-11' to be generated")
        }
        
        let filterExpectation = XCTestExpectation(description: "Filtered accounts for selected month and computed totals")
        sut.$filteredAccountsBySelectedMonth
            .dropFirst()
            .sink { filtered in
                // Assert: each account has only the selected month in monthlyHistory
                XCTAssertEqual(filtered.count, 2, "Should include both accounts after filtering")
                
                // Savings checks (id 101)
                if let savings = filtered.first(where: { $0.id == 101 }) {
                    XCTAssertEqual(savings.monthlyHistory.count, 1, "Savings should have exactly one month after filter")
                    XCTAssertEqual(savings.monthlyHistory.first?.monthKey, "2025-11")
                    XCTAssertEqual(savings.monthlyHistory.first?.closingBalance, 150.0)
                    XCTAssertEqual(savings.monthlyHistory.first?.contribution, 15.0)
                    XCTAssertEqual(savings.monthlyHistory.first?.openingBalance, 120.0)
                    XCTAssertEqual(savings.monthlyHistory.first?.exchangeRate, 1.1)
                } else {
                    XCTFail("Filtered savings account not found")
                }
                
                // Loan checks (id 202)
                if let loan = filtered.first(where: { $0.id == 202 }) {
                    XCTAssertEqual(loan.monthlyHistory.count, 1, "Loan should have exactly one month after filter")
                    XCTAssertEqual(loan.monthlyHistory.first?.monthKey, "2025-11")
                    XCTAssertEqual(loan.monthlyHistory.first?.closingBalance, 160.0)
                    XCTAssertEqual(loan.monthlyHistory.first?.contribution, 25.0)
                    XCTAssertEqual(loan.monthlyHistory.first?.openingBalance, 180.0)
                    XCTAssertEqual(loan.monthlyHistory.first?.exchangeRate, 1.0)
                } else {
                    XCTFail("Filtered loan account not found")
                }
                filterExpectation.fulfill()
            }
            .store(in: &cancellables)
        
        let pnlExpectation = XCTestExpectation(description: "Computed totals")
        sut.$totalPnL
            .dropFirst()
            .sink { pnl in
                // Totals math:
                // totalClosing = SAVING: 150 * 1.1 = 165
                //               LOAN:   160 * 1.0 = 160 -> negate => -160
                //             => 165 + (-160) = 5
                // totalContribution = (15 * 1.1) + (25 * 1.0) = 16.5 + 25 = 41.5
                // totalOpening = SAVING: 120 * 1.1 = 132
                //                LOAN:   180 * 1.0 = 180 -> negate => -180
                //              => 132 + (-180) = -48
                // totalPnL = totalClosing - totalOpening - totalContribution
                //         = 5 - (-48) - 41.5 = 5 + 48 - 41.5 = 11.5
                XCTAssertEqual(self.sut.totalClosing, 5.0, accuracy: 0.0001, "totalClosing should reflect exchange rates and LOAN sign")
                XCTAssertEqual(self.sut.totalContribution, 41.5, accuracy: 0.0001, "totalContribution should reflect exchange rates")
                XCTAssertEqual(pnl, 11.5, accuracy: 0.0001, "totalPnL should match derived formula")
                
                pnlExpectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Act: set the selected month to trigger filtering
        sut.selectedMonthYear = targetMonth
        
        wait(for: [filterExpectation], timeout: 1.0)
        wait(for: [pnlExpectation], timeout: 1.0)
    }
}
