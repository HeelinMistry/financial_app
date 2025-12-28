//
//  AppCoordinator.swift
//  financial_app
//
//  Created by Heelin Mistry on 2025/12/24.
//

import SwiftUI
import Combine

class AppCoordinator: Coordinator, RefreshUserAccounts {    
    @Published var isAuthenticated: Bool = false
    
    @Published var navigationPath = NavigationPath() // Used for navigation stacks
    @Published var currentSheet: Destination?      // Used for sheets
    @Published var currentModal: Destination?
    @Published var currentAlert: AlertItem?        // Used for alerts/popups
    @Published var currentToast: Toast?
    
    let accountDidChange = PassthroughSubject<Void, Never>()
    
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
                .presentationDetents([.medium, .large])
        }
        .fullScreenCover(item: modalBinding) { destinationWrapper in
            self.view(for: destinationWrapper.destination)
        }
        .alert(item: alertBinding) { alertItem in
            guard let secondaryButton = alertItem.secondaryButton else  {
                return Alert(
                    title: alertItem.title,
                    message: alertItem.message,
                    dismissButton: alertItem.primaryButton
                )
            }
            return Alert(
                title: alertItem.title,
                message: alertItem.message,
                primaryButton: alertItem.primaryButton,
                secondaryButton: secondaryButton
            )
        }
        .overlay(alignment: .top) { // Use overlay for positioning
            if let toast = currentToast {
                ToastView(toast: toast)
                    .transition(.move(edge: .top).combined(with: .opacity))
                // Animation applied only to the toast's appearance/disappearance
                    .animation(.easeInOut(duration: 0.3), value: toast)
            }
        }
        // Set animation value on the entire contentView for the overlay change
        .animation(.default, value: currentToast)
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
        default:
            break
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
        case .registration:
            RegistrationView(viewModel: RegistrationViewModel(coordinator: self))
        case .addAccount:
            AccountFormView(viewModel: AccountFormViewModel(coordinator: self))
        case .updateAccountHistory(let account):
            AccountHistoryFormView(viewModel: AccountHistoryFormViewModel(account: account, coordinator: self))
        default:
            Text("Unknown Destination")
        }
    }
    
    func dismissModal() {
        self.currentModal = nil
    }
    
    func dismissSheet() {
        self.currentSheet = nil
    }
    
    // MARK: - Toast Logic
    
    func presentToast(style: Toast.ToastStyle, message: String) {
        let newToast = Toast(style: style, message: message)
        self.currentToast = newToast
        DispatchQueue.main.asyncAfter(deadline: .now() + newToast.duration) { [weak self] in
            if self?.currentToast == newToast {
                self?.currentToast = nil
            }
        }
    }
    
    // Convenience methods for ViewModels
    func presentSuccessToast(message: String) {
        presentToast(style: .success, message: message)
    }
    
    func presentFailureToast(message: String) {
        presentToast(style: .failure, message: message)
    }
    
    // MARK: - Alert Logic (New Version)
    
    func presentConfirmationAlert(
        title: String,
        message: String,
        confirmTitle: String,
        confirmRole: ButtonRole,
        confirmAction: @escaping () -> Void // 🚨 The code block for the primary action
    ) {
        var primaryButton: Alert.Button
        switch confirmRole {
        case .destructive:
            primaryButton = Alert.Button.destructive(Text(confirmTitle)) {
                confirmAction()
            }
        default:
            primaryButton = Alert.Button.default(Text(confirmTitle)) {
                confirmAction()
            }
        }
            // 2. Define the Cancel/Secondary button
        let secondaryButton = Alert.Button.cancel()
        // 3. Create the new AlertItem with custom actions
        self.currentAlert = AlertItem(
            title: Text(title),
            message: Text(message),
            primaryAction: primaryButton,
            secondaryAction: secondaryButton
        )
    }
}
