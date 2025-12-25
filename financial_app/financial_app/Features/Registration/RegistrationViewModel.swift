//
//  RegistrationViewModel.swift
//  financial_app
//
//  Created by Heelin Mistry on 2025/12/25.
//

import Combine
import Foundation

final class RegistrationViewModel: ObservableObject {
    
    // Basic registration fields
    @Published var user = ""
    
    // Error and Loading states
    @Published var isLoading = false
    
    weak var coordinator: (any Coordinator)?
    
    private var cancellables = Set<AnyCancellable>()
    private let apiService: APIServicing
    
    // MARK: - Computed Properties
    
    /// Determines if the login button should be disabled based on validation rules.
    /// Requires a name of 6+ characters and a non-empty password.
    var isRegisterButtonDisabled: Bool {
        return user.count < 6
    }
    
    init(apiService: APIServicing = APIService.shared, coordinator: (any Coordinator)?) {
        self.apiService = apiService
        self.coordinator = coordinator
    }
    
    func registerUser() {
        guard !isRegisterButtonDisabled else { return }
        isLoading = true
        
        let registerData = LoginData(name: user)
        let endpoint = APIEndpoint.register(data: registerData)
        
        apiService.request(endpoint: endpoint) // Expecting TokenResponse (or Int, based on your code)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                
                switch completion {
                case .failure:
                    self?.closeRegistration()
                    self?.coordinator?.presentFailureToast(message: "User not created! Please try again.")
                case .finished:
                    break
                }
            } receiveValue: { [weak self] (data: Int) in
                self?.coordinator?.dismissModal()
                self?.coordinator?.presentSuccessToast(message: "User created successfully! Please login")
            }
            .store(in: &cancellables)
    }
    
    func closeRegistration() {
        coordinator?.dismissModal()
    }
}
