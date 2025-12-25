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
}

// Global enum for all possible navigation routes in the app
enum Destination: Hashable {
    case login
    case userAccounts
//    case postsList
//    case settings
    indirect case presentSheet(destination: Destination)
    indirect case presentModal(destination: Destination)
    case presentAlert(title: String, message: String)
    // Add more cases for specific sheets/alerts/popups as needed
}
