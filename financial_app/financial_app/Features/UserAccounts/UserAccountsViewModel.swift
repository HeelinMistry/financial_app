//
//  UserAccountsViewModel.swift
//  financial_app
//
//  Created by Heelin Mistry on 2025/12/24.
//

import Combine
import Foundation

class UserAccountsViewModel: ObservableObject {
    
    @Published var accounts: [Account] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    weak var coordinator: (any Coordinator)?
    private let apiService: APIService
    private var cancellables = Set<AnyCancellable>()
    
    init(apiService: APIService = APIService.shared, coordinator: (any Coordinator)?) {
        self.apiService = apiService
        self.coordinator = coordinator
    }
    
    func fetchUserAccounts() {
        isLoading = true
        errorMessage = nil
        apiService.request(endpoint: .userAccounts)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] (accounts: [Account]) in
                self?.accounts = accounts
            }
            .store(in: &cancellables)
    }
}
