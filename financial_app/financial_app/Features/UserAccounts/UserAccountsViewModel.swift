/**
 A view model responsible for handling user account logic,
 managing the state (loading, errors), and coordinating navigation
 upon successful account loading.
 
 The authentication process involves:
 1. Calling the `UserAccountsRepository` (which uses APIService) via Combine.
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
    
    /// The loading indicator when repository loading
    @Published var isLoading = false
    
    weak var coordinator: (any Coordinator)?
    private let repository: UserAccountsRepository
    private var cancellables = Set<AnyCancellable>()
    
    // Used to prevent redundant UI-triggered loads (e.g., onAppear firing twice)
    private var isFetching = false
    
    init(
        repository: UserAccountsRepository = DefaultUserAccountsRepository(),
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
