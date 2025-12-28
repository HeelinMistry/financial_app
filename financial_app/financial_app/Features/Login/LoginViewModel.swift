/**
 A view model responsible for handling user authentication logic,
 managing the state (loading, errors), and coordinating navigation
 upon successful login.
 
 The authentication process involves:
 1. Local validation of user input.
 2. Calling the `APIService` via the Combine pipeline.
 3. Storing the received `TokenResponse` in `AuthManager`.
 
 - Author: Heelin
 - Date: 2025-12-24
 */

import Foundation
import Combine

class LoginViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// The user entered by the user.
    @Published var user = ""
    
    /// Indicates whether an API request is currently in progress.
    @Published var isLoading = false
    
    /// Indicates the error returned by the API
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let apiService: APIServicing
    
    weak var coordinator: (any Coordinator)?
    
    init(apiService: APIServicing = APIService.shared, coordinator: (any Coordinator)?) {
        self.apiService = apiService
        self.coordinator = coordinator
    }
    
    // MARK: - Computed Properties
    
    /// Determines if the login button should be disabled based on validation rules.
    /// Requires a name of 6+ characters and a non-empty password.
    var isLoginButtonDisabled: Bool {
        return user.count < 6
    }
    
    // MARK: - Public Methods
    
    /**
     Initiates the login process by validating fields and executing the
     API request via the injected `APIService`.
     
     On success: Stores the token and navigates to `.userAccounts`.
     On failure: Sets the `errorMessage` and clears the loading state.
     */
    func login() {
        guard !isLoginButtonDisabled else { return }
        isLoading = true
        errorMessage = nil
        let loginData = LoginData(name: user)
        let endpoint = APIEndpoint.login(loginData)
        
        apiService.request(endpoint: endpoint) // Expecting TokenResponse
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .failure(_):
                    self?.coordinator?.presentFailureToast(message: "Login Failed.")
                case .finished:
                    break
                }
                self?.isLoading = false
            } receiveValue: { [weak self] (tokenResponse: TokenResponse) in
                AuthManager.shared.setToken(tokenResponse.token)
                self?.coordinator?.navigate(to: .userAccounts)
            }
            .store(in: &cancellables)
    }
}
