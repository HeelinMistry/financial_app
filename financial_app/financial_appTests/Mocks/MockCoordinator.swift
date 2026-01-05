//
//  MockCoordinator.swift
//  financial_app
//
//  Created by Heelin Mistry on 2025/12/25.
//

import SwiftUI
import Combine

class MockCoordinator: Coordinator, RefreshUserAccounts {
    
    var contentView: some View { Text("") }
    var lastDestination: Destination?
    
    var didTriggerRefresh = false
    var dismissedModal = false
    var dismissedSheet = false
    var presentSuccessToastCalled = false
    var presentFailureToastCalled = false
    var lastToastMessage: String?
    
    let accountDidChange = PassthroughSubject<Void, Never>()

    init() {}
    
    func start() {}
    
    // Implementation of navigate method
    func navigate(to destination: Destination) {
        self.lastDestination = destination
    }
    
    func presentRegistration() {}
    
    func dismissModal() {
        dismissedModal = true
    }
    
    func dismissSheet() {
        dismissedSheet = true
    }
    
    func presentToast(style: Toast.ToastStyle, message: String) {}
    
    func presentSuccessToast(message: String) {
        presentSuccessToastCalled = true
        lastToastMessage = message
    }
    
    func presentFailureToast(message: String) {
        presentFailureToastCalled = true
        lastToastMessage = message
    }
    
    func presentConfirmationAlert(
        title: String,
        message: String,
        confirmTitle: String,
        confirmRole: ButtonRole,
        confirmAction: @escaping () -> Void) {
        
    }
}
