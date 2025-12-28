//
//  AccountFormViewModel.swift
//  financial_app
//
//  Created by Heelin Mistry on 2025/12/26.
//

import Combine
import Foundation

final class AccountFormViewModel: ObservableObject {
    
    // Basic registration fields
    @Published var name = ""
    @Published var type: AccountType = .SAVING
    @Published var isLoading = false
    
    weak var coordinator: (any Coordinator)?
    
    private var cancellables = Set<AnyCancellable>()
    private let apiService: APIServicing
    
    // MARK: - Computed Properties
    
    /// Determines if the save button should be disabled based on validation rules.
    var isSaveButtonDisabled: Bool {
        return name.isEmpty
    }
    
    init(apiService: APIServicing = APIService.shared, coordinator: (any Coordinator)?) {
        self.apiService = apiService
        self.coordinator = coordinator
    }
    
    func addAccount() {
        guard !isSaveButtonDisabled else { return }
        isLoading = true
        
        let accountDetails = AccountDetails(
            name: name,
            type: type
        )
        let endpoint = APIEndpoint.createAccount(accountDetails)
        
        apiService.request(endpoint: endpoint) // Expecting TokenResponse (or Int, based on your code)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                
                switch completion {
                case .failure:
                    self?.closeAccountsForm()
                    self?.coordinator?.presentFailureToast(message: "Account not created! Please try again.")
                case .finished:
                    break
                }
            } receiveValue: { [weak self] (data: Int) in
                self?.closeAccountsForm()
                guard let self = self,
                      // 🚨 Safely cast the coordinator to the new protocol to access the publisher
                let publisher = self.coordinator as? RefreshUserAccounts else { return }
                publisher.accountDidChange.send()
                coordinator?.presentSuccessToast(message: "Account created successfully!")
            }
            .store(in: &cancellables)
    }
    
    func closeAccountsForm() {
        coordinator?.dismissSheet()
    }
}
