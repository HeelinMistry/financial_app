//
//  AppCoordinator.swift
//  financial_app
//
//  Created by Heelin Mistry on 2025/12/24.
//

import SwiftUI
import Combine

class AppCoordinator: Coordinator {
    @Published var isAuthenticated: Bool = false
    
    @Published var navigationPath = NavigationPath() // Used for navigation stacks
    @Published var currentSheet: Destination?      // Used for sheets
    @Published var currentModal: Destination?      // Used for full-screen covers
    @Published var currentAlert: AlertItem?        // Used for alerts/popups
    
    // A simplified way to store alert data
    struct AlertItem: Identifiable {
        let id = UUID()
        let title: Text
        let message: Text
        var dismissButton: Alert.Button? = .default(Text("OK"))
    }
    
    var sheetBinding: Binding<DestinationWrapper?> {
        Binding<DestinationWrapper?>(
            get: {
                // When reading, wrap the Destination in the Identifiable wrapper
                self.currentSheet.map(DestinationWrapper.init)
            },
            set: { identifiableWrapper in
                // When writing (dismissing), unwrap the wrapper back to Destination?
                self.currentSheet = identifiableWrapper?.destination
            }
        )
    }
    
    // You can create a similar property for modals if you want:
    var modalBinding: Binding<DestinationWrapper?> {
        // Implementation is identical to sheetBinding, using self.currentModal
        Binding<DestinationWrapper?>(
            get: { self.currentModal.map(DestinationWrapper.init) },
            set: { self.currentModal = $0?.destination }
        )
    }
    
    var alertBinding: Binding<AlertItem?> {
        Binding(
            get: { self.currentAlert },
            set: { self.currentAlert = $0 }
        )
    }
    
    // Determines which screen to show first (e.g., based on authentication)
    var contentView: some View {
        Group {
            if isAuthenticated {
                self.view(for: .userAccounts)
            } else {
                self.view(for: .login)
            }
        }
        .environmentObject(self) // Pass the coordinator down the hierarchy
        .sheet(item: sheetBinding) { destinationWrapper in
            self.view(for: destinationWrapper.destination)
        }
        .fullScreenCover(item: modalBinding) { destinationWrapper in
            self.view(for: destinationWrapper.destination)
        }
        .alert(item: alertBinding) { alertItem in
            Alert(title: alertItem.title,
                  message: alertItem.message,
                  dismissButton: alertItem.dismissButton)
        }
    }
    
    func start() {
        // Initial setup logic
    }
    
    // MARK: - Navigation Logic
    
    func navigate(to destination: Destination) {
        switch destination {
        case .login:
            AuthManager.shared.clearToken()
            isAuthenticated = false
            navigationPath = NavigationPath()
        case .userAccounts:
            if AuthManager.shared.isAuthenticated {
                isAuthenticated = true
                navigationPath = NavigationPath()
            }
        case .presentSheet(let childDestination):
            self.currentSheet = childDestination
        case .presentModal(let childDestination):
            self.currentModal = childDestination
        case .presentAlert(let title, let message):
            self.currentAlert = AlertItem(title: Text(title), message: Text(message))
        }
    }
    
    // MARK: - View Factory
    
    @ViewBuilder
    func view(for destination: Destination) -> some View {
        switch destination {
        case .login:
            LoginView(viewModel: LoginViewModel(coordinator: self))
        case .userAccounts:
            UserAccountsView(viewModel: UserAccountsViewModel(coordinator: self))
        default:
            Text("Unknown Destination")
        }
    }
}
