//
//  AlertItem.swift
//  financial_app
//
//  Created by Heelin Mistry on 2025/12/26.
//

import SwiftUI

struct AlertItem: Identifiable {
    let id = UUID()
    let title: Text
    let message: Text
    
    // 🚨 NEW: Actions (Optional)
    let primaryButton: Alert.Button
    let secondaryButton: Alert.Button?
    
    // Convenience initializer for simple dismiss (old behavior)
    init(title: Text, message: Text, primaryButton: Alert.Button) {
        self.title = title
        self.message = message
        self.primaryButton = primaryButton
        self.secondaryButton = nil
    }
    
    // 🚨 NEW: Initializer for custom actions
    init(title: Text, message: Text, primaryAction: Alert.Button, secondaryAction: Alert.Button?) {
        self.title = title
        self.message = message
        self.primaryButton = primaryAction
        self.secondaryButton = secondaryAction
    }
}

//struct AlertButton: Identifiable {
//    let id = UUID()
//    let title: Text
//    let role: ButtonRole?
//    // 🚨 The closure to execute when the button is tapped
//    let action: (() -> Void)?
//    
//    // Convenience initializer
//    init(title: Text, role: ButtonRole? = nil, action: (() -> Void)?) {
//        self.title = title
//        self.role = role
//        self.action = action
//    }
//}
