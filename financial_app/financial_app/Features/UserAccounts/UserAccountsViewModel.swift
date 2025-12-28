/**
 A view model responsible for handling user account logic,
 managing the state (loading, errors), and coordinating navigation
 upon successful account loading.
 
 The authentication process involves:
 1. Calling the `APIService` via the Combine pipeline.
 2. Storing the received `[Account]`.
 
 - Author: Heelin
 - Date: 2025-12-24
 */

import Combine
import Foundation

class UserAccountsViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// The user accounts.
    @Published var accounts: [Account] = []
    
    /// The loading indicator when API service loading
    @Published var isLoading = false
    
    weak var coordinator: (any Coordinator)?
    private let apiService: APIServicing
    private var cancellables = Set<AnyCancellable>()
    
    init(apiService: APIServicing = APIService.shared, coordinator: (any Coordinator)?) {
        self.apiService = apiService
        self.coordinator = coordinator
        setupBindings()
    }
    
    private func setupBindings() {
        guard let publisher = coordinator as? RefreshUserAccounts else { return }
        
        publisher.accountDidChange
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                print("Account change detected. Fetching accounts...")
                self?.fetchUserAccounts()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    /**
     Initiates the user accounts process by executing the
     API request via the injected `APIService`.
     
     On success: Stores the accounts.
     On failure: Sets the `errorMessage` and clears the loading state.
     */
    func fetchUserAccounts() {
        isLoading = true
        apiService.request(endpoint: .userAccounts)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure = completion {
                    self?.coordinator?.presentFailureToast(message: "Could not retrieve user accounts")
                }
                self?.isLoading = false
            } receiveValue: { [weak self] (accounts: [Account]) in
                self?.accounts = accounts
            }
            .store(in: &cancellables)
    }
    
    /**
     Initiates the create account flow
     */
    func showAddAccounts() {
        coordinator?.navigate(to: .presentSheet(destination: .addAccount))
    }
}
