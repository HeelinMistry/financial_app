//
//  SummaryViewModel.swift
//  financial_app
//
//  Created by Heelin Mistry on 2026/01/28.
//

import Combine
import Foundation

class SummaryViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var accounts: [Account] = []
    @Published var isLoading = false
    
    @Published var availableMonths: [MonthYear] = []
    @Published var selectedMonthYear: MonthYear? {
        didSet {
            updateAccountsWithFilter()
        }
    }
    @Published var filteredAccountsBySelectedMonth: [Account] = []
    @Published var totalClosing: Double = 0.00
    @Published var totalContribution: Double = 0.00
    @Published var totalPnL: Double = 0.00
    
    weak var coordinator: (any Coordinator)?
    private let repository: UserAccountsRepository
    private var cancellables = Set<AnyCancellable>()
    
    // Used to prevent redundant UI-triggered loads (e.g., onAppear firing twice)
    private var isFetching = false
    
    init(
        repository: UserAccountsRepository = DefaultUserAccountsRepository.shared,
        coordinator: (any Coordinator)?
    ) {
        self.repository = repository
        self.coordinator = coordinator
        setupBindings()
    }
    
    private func setupBindings() {
        guard let publisher = coordinator as? RefreshUserAccounts else { return }
        
        publisher.accountDidChange
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                print("Account change detected. Fetching accounts (force refresh)...")
                self?.fetchUserAccounts(forceRefresh: true)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    /**
     Initiates the user accounts process by executing the
     repository request, which caches and de-duplicates network calls.
     
     On success: Stores the accounts.
     On failure: Sets the `errorMessage` and clears the loading state.
     */
    func fetchUserAccounts(forceRefresh: Bool = false) {
        // Avoid flipping UI state multiple times if an identical fetch is already in progress
        if isFetching { return }
        isFetching = true
        isLoading = true
        
        repository.accounts(forceRefresh: forceRefresh)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure = completion {
                    self?.coordinator?.presentFailureToast(message: "Could not retrieve user accounts")
                }
                self?.isLoading = false
                self?.isFetching = false
            } receiveValue: { [weak self] (accounts: [Account]) in
                self?.accounts = accounts
                self?.generateMonths(accounts)
            }
            .store(in: &cancellables)
    }
    
    private func generateMonths(_ accounts: [Account]) {
        var months: [MonthYear] = []
        var seenNames = Set<String>()

        
        // Formatters for display and key
        let keyFormatter = DateFormatter()
        keyFormatter.dateFormat = "yyyy-MM"
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "MMM yyyy" 
        
        for account in accounts {
            for monthHistory in account.monthlyHistory {
                if let date = keyFormatter.date(from: monthHistory.monthKey) {
                    let displayName = displayFormatter.string(from: date)
                    
                    // Only proceed if we haven't seen this name yet
                    if !seenNames.contains(displayName) {
                        let monthYear = MonthYear(
                            date: date,
                            monthKey: monthHistory.monthKey,
                            displayName: displayName
                        )
                        
                        months.append(monthYear)
                        seenNames.insert(displayName) // Mark it as seen
                    }
                }
            }
        }
        self.availableMonths = months
    }
    
    private func updateAccountsWithFilter() {
        guard let selected = selectedMonthYear else {
            filteredAccountsBySelectedMonth = []
            return
        }
        
        let key = selected.monthKey
        
        // Map each account to a filtered version containing only the matching month history (if present)
        let filtered = accounts.map { account -> Account in
            if let match = account.monthlyHistory.first(where: { $0.monthKey == key }) {
                return Account(
                    id: account.id,
                    ownerId: account.ownerId,
                    name: account.name,
                    type: account.type,
                    monthlyHistory: [match]
                )
            } else {
                // Include account with empty monthlyHistory (or return the original to keep full history)
                return Account(
                    id: account.id,
                    ownerId: account.ownerId,
                    name: account.name,
                    type: account.type,
                    monthlyHistory: []
                )
            }
        }
        
        filteredAccountsBySelectedMonth = filtered
        
        totalClosing = 0.0
        for account in filteredAccountsBySelectedMonth {
            for month in account.monthlyHistory {
                var weightedBalance = (month.closingBalance ?? 0.00) * month.exchangeRate
                if account.type == .LOAN {
                    weightedBalance *= -1.00
                }
                totalClosing += weightedBalance
            }
        }
        
        totalContribution = 0.0
        for account in filteredAccountsBySelectedMonth {
            for month in account.monthlyHistory {
                let weightedBalance = (month.contribution ?? 0.00) * month.exchangeRate
                totalContribution += weightedBalance
            }
        }
        
        var totalOpening = 0.0
        for account in filteredAccountsBySelectedMonth {
            for month in account.monthlyHistory {
                var weightedBalance = (month.openingBalance ?? 0.00) * month.exchangeRate
                if account.type == .LOAN {
                    weightedBalance *= -1.00
                }
                totalOpening += weightedBalance
            }
        }
        totalPnL = totalClosing - totalOpening - totalContribution

    }
}

