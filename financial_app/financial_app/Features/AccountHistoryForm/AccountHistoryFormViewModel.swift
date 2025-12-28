//
//  AccountHistoryFormViewModel.swift
//  financial_app
//
//  Created by Heelin Mistry on 2025/12/27.
//

import Combine
import Foundation

final class AccountHistoryFormViewModel: ObservableObject {
    
    private var account: Account
    private var monthlyHistory: [MonthlyHistory] = []
    private var originalMonthlyHistory: MonthlyHistory?
    
    @Published var selectedMonth: MonthlyHistory?
    @Published var availableMonths: [MonthYear] = []
    @Published var selectedMonthYear: MonthYear?
    @Published var isLoading = false
    
    @Published var openingBalanceString: String = ""
    @Published var closingBalanceString: String = ""
    @Published var contributionString: String = ""
    @Published var exchangeRateString: String = ""
    @Published var interestRateString: String = ""
    @Published var termsLeftString: String = ""
    
    weak var coordinator: (any Coordinator)?
    private let apiService: APIServicing
    private var cancellables = Set<AnyCancellable>()
    
    var latestConvertedBalance: Double {
        let closing = account.monthlyHistory.last?.closingBalance ?? 0.0
        let rate = account.monthlyHistory.last?.exchangeRate ?? 0.0
        return closing * rate
    }
    
    var saveButtonText: String {
        // Use nil coalescing and optional chaining to safely get the month display name
        if let displayName = selectedMonthYear?.displayName {
            return "Save History for \(displayName)"
        } else {
            return "Select Month to Begin"
        }
    }
    
    var isLoanAccountType: Bool {
        account.type == .LOAN
    }
    
    init(account: Account, apiService: APIServicing = APIService.shared, coordinator: (any Coordinator)?) {
        self.account = account
        self.apiService = apiService
        self.coordinator = coordinator
        self.monthlyHistory = account.monthlyHistory
        self.selectedMonth = monthlyHistory.last
        
        self.generateMonths() // 🚨 Call this in the initializer
//        self.selectedMonthYear = self.availableMonths.first(where: {
//            $0.monthKey == self.selectedMonth?.monthKey
//        })
        if let firstMonth = self.availableMonths.first {
            updateSelectedMonth(with: firstMonth)
            self.selectedMonthYear = firstMonth
        }
        if let month = self.selectedMonth {
            self.updateStringsFromMonthlyHistory(month)
        }
        if let lastHistory = monthlyHistory.last {
            self.originalMonthlyHistory = lastHistory
        }
    }
    
    // MARK: - String/Double Conversion
    
    private func updateStringsFromMonthlyHistory(_ history: MonthlyHistory) {
        if let openingBalance = history.openingBalance {
            self.openingBalanceString = String(format: "%.2f", openingBalance)
        } else {
            self.openingBalanceString = ""
        }
        if let closingBalance = history.closingBalance {
            self.closingBalanceString = String(format: "%.2f", closingBalance)
        } else {
            self.closingBalanceString = ""
        }
        if let contribution = history.contribution {
            self.contributionString = String(format: "%.2f", contribution)
        } else {
            self.contributionString = ""
        }
        exchangeRateString = String(format: "%.2f", history.exchangeRate)
        if let interestRate = history.interestRate {
            self.interestRateString = String(format: "%.2f", interestRate)
        } else {
            self.interestRateString = ""
        }
        if let termsLeft = history.termsLeft {
            self.termsLeftString = String(format: "%f", termsLeft)
        } else {
            self.termsLeftString = ""
        }
    }
    
    // 🚨 Update the monthly history object based on the current strings
    func updateMonthlyHistoryFromStrings() {
        guard var month = selectedMonth else { return }
        
        // 1. Convert strings to Doubles
        let ob = Double(openingBalanceString) ?? month.openingBalance
        let cb = Double(closingBalanceString) ?? month.closingBalance
        let co = Double(contributionString) ?? month.contribution
        let er = Double(exchangeRateString) ?? month.exchangeRate
        let ir = Double(interestRateString) ?? month.interestRate
        let tl = Int(termsLeftString) ?? month.termsLeft
        
        // 2. 🚨 Apply rounding to all currency-related Doubles before storing
        month.openingBalance = ob?.rounded(toPlaces: 2)
        month.closingBalance = cb?.rounded(toPlaces: 2)
        month.contribution = co?.rounded(toPlaces: 2)
        month.exchangeRate = er.rounded(toPlaces: 4) 
        month.interestRate = ir?.rounded(toPlaces: 2)
        month.termsLeft = tl
        
        // Update the published property
        self.selectedMonth = month
    }
    
    var hasChanges: Bool {
        guard let original = originalMonthlyHistory else {
            // If there's no original data, assume it's a new entry and always allow saving (true)
            return true
        }
        
        // 1. Safely convert current strings to Doubles
        let currentOB = Double(openingBalanceString)?.rounded(toPlaces: 2)
        let currentCB = Double(closingBalanceString)?.rounded(toPlaces: 2)
        let currentCO = Double(contributionString)?.rounded(toPlaces: 2)
        let currentER = Double(exchangeRateString)?.rounded(toPlaces: 4)
        let currentIR = Double(interestRateString)?.rounded(toPlaces: 2)
        let currentTL = Int(termsLeftString)
        
        // 2. Compare the CURRENT rounded values with the ORIGINAL stored values
        // Note: Using standard == comparison on rounded doubles is generally acceptable here.
        let obChanged = currentOB != original.openingBalance?.rounded(toPlaces: 2)
        let cbChanged = currentCB != original.closingBalance?.rounded(toPlaces: 2)
        let coChanged = currentCO != original.contribution?.rounded(toPlaces: 2)
        let erChanged = currentER != original.exchangeRate.rounded(toPlaces: 4)
        let irChanged = currentIR != original.interestRate?.rounded(toPlaces: 2)
        let tlChanged = currentTL != original.termsLeft
        
        return obChanged || cbChanged || coChanged || erChanged || irChanged || tlChanged
    }
    
    // MARK: - Computed Properties
    
    /// Determines if the save button should be disabled based on validation rules.
    var isSaveButtonDisabled: Bool {
        let inputsValid = Double(openingBalanceString) != nil &&
        Double(closingBalanceString) != nil &&
        Double(contributionString) != nil
        
        // 2. There must be actual changes AND a selected month
        let dataChanged = hasChanges
        
        // Button is disabled if inputs are invalid OR no data has changed.
        return !inputsValid || !dataChanged
    }
    
    func updateAccountMonthHistory() {
        updateMonthlyHistoryFromStrings()
        guard !isSaveButtonDisabled,
              let monthRequest = selectedMonth else { return }
        isLoading = true
        
        let endpoint = APIEndpoint.updateAccount(accountId: account.id, requestData: monthRequest)
        apiService.request(endpoint: endpoint)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                
                switch completion {
                case .failure:
                    self?.closeAccountsForm()
                    self?.coordinator?.presentFailureToast(message: "Account history not updated! Please try again.")
                case .finished:
                    break
                }
            } receiveValue: { [weak self] (data: MonthlyHistory) in
                self?.closeAccountsForm()
                guard let self = self,
                      // 🚨 Safely cast the coordinator to the new protocol to access the publisher
                      let publisher = self.coordinator as? RefreshUserAccounts else { return }
                publisher.accountDidChange.send()
                coordinator?.presentSuccessToast(message: "Account history updated successfully!")
            }
            .store(in: &cancellables)
    }
    
    func closeAccountsForm() {
        coordinator?.dismissSheet()
    }
    
    /// Checks if a MonthYear object has a corresponding MonthlyHistory entry stored on the account.
    func historyExists(for monthYear: MonthYear) -> Bool {
        // We check the full, original list of history items for the monthKey
        return monthlyHistory.contains { $0.monthKey == monthYear.monthKey }
    }
    
    /// Converts a Date object to the "yyyy-MM" monthKey string.
    private func dateToMonthKey(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: date)
    }
    
    /// Updates the ViewModel's selectedMonth based on the DatePicker input.
    func updateSelectedMonth(with monthYear: MonthYear) {
        let newMonthKey = monthYear.monthKey
        
        // 1. Try to find existing history
        if let existingMonth = monthlyHistory.first(where: { $0.monthKey == newMonthKey }) {
            self.selectedMonth = existingMonth
        } else {
            self.selectedMonth = MonthlyHistory(
                monthKey: newMonthKey
            )
        }
        if let month = self.selectedMonth {
            self.updateStringsFromMonthlyHistory(month)
            self.originalMonthlyHistory = month
        }
    }
    
    private func generateMonths(count: Int = 18) {
        var months: [MonthYear] = []
        let calendar = Calendar.current
        let today = Date()
        
        // Formatters for display and key
        let keyFormatter = DateFormatter()
        keyFormatter.dateFormat = "yyyy-MM"
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "MMM yyyy" // e.g., Dec 2025
        
        // Generate months, starting from the current month backwards
        for i in 0..<count {
            if let date = calendar.date(byAdding: .month, value: -i, to: today) {
                let monthYear = MonthYear(
                    date: date,
                    monthKey: keyFormatter.string(from: date),
                    displayName: displayFormatter.string(from: date)
                )
                months.append(monthYear)
            }
        }
        months.remove(at: 0)
        self.availableMonths = months
    }
}
