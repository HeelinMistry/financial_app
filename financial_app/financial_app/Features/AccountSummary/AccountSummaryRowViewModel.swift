//
//  AccountSummaryRowViewModel.swift
//  financial_app
//
//  Created by Heelin Mistry on 2025/12/27.
//

import Foundation
import Combine
import SwiftUI

final class AccountSummaryRowViewModel: ObservableObject {
    
    @Published var account: Account // The data for this specific row
    @Published var isDeleting: Bool = false
    @Published var deleteError: String?
    
    weak var coordinator: (any Coordinator)?
    private let apiService: APIServicing
    private var cancellables = Set<AnyCancellable>()
    
    var latestConvertedBalance: Double {
        let closing = account.monthlyHistory.last?.closingBalance ?? 0.0
        let rate = account.monthlyHistory.last?.exchangeRate ?? 0.0
        return closing * rate
    }
    
    init(account: Account, apiService: APIServicing = APIService.shared, coordinator: (any Coordinator)?) {
        self.account = account
        self.apiService = apiService
        self.coordinator = coordinator
    }
    
    // 🚨 Action: Present the Edit Sheet
    func editAccount() {
        guard let appCoordinator = coordinator as? AppCoordinator else { return }
        appCoordinator.navigate(to: .presentSheet(destination: .updateAccountHistory(account: account)))
    }
    
    // 🚨 Action: Handle the API Delete Call
    func deleteAccount() {
        isDeleting = true
        deleteError = nil
        
        // This is a placeholder for your actual API call
        let endpoint = APIEndpoint.deleteAccount(account)
        
        apiService.request(endpoint: endpoint)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isDeleting = false
                switch completion {
                case .failure(let error):
                    switch error {
                    case .noContentSuccess:
                        self?.coordinator?.dismissSheet()
                        (self?.coordinator as? RefreshUserAccounts)?.accountDidChange.send()
                        self?.coordinator?.presentSuccessToast(message: "Account '\(self?.account.name ?? "Account")' deleted.")
                    default:
                        self?.coordinator?.presentFailureToast(message: "Failed to delete account: \(self?.account.name ?? "Account")")
                    }
                    
                case .finished:
                    self?.coordinator?.presentSuccessToast(message: "Account '\(self?.account.name ?? "Account")' deleted.")
                }
            } receiveValue: { (data: EmptyResponse) in
            }
            .store(in: &cancellables) // Assume cancellables is defined
    }
}
