//
//  Coordinator.swift
//  financial_app
//
//  Created by Heelin Mistry on 2025/12/24.
//

import SwiftUI

protocol Coordinator: ObservableObject {
    associatedtype ContentView: View
    
    // The main view the Coordinator is responsible for presenting
    var contentView: ContentView { get }

    
    // A function to handle navigation events triggered from ViewModels
    func start()
    func navigate(to destination: Destination)
    
    func dismissModal()
    func dismissSheet()
    
    // MARK: - Toast Logic

    func presentToast(style: Toast.ToastStyle, message: String)
    
    // Convenience methods for ViewModels
    func presentSuccessToast(message: String)
    func presentFailureToast(message: String)
    
    func presentConfirmationAlert(
        title: String,
        message: String,
        confirmTitle: String,
        confirmRole: ButtonRole,
        confirmAction: @escaping () -> Void // 🚨 The code block for the primary action
    )
}

// Global enum for all possible navigation routes in the app
enum Destination: Hashable {
    case registration
    case login
    case userAccounts
    case addAccount
    case updateAccountHistory(account: Account)
    indirect case presentSheet(destination: Destination)
    indirect case presentModal(destination: Destination)
}
