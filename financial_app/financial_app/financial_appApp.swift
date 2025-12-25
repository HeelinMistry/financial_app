//
//  financial_appApp.swift
//  financial_app
//
//  Created by Heelin Mistry on 2025/12/24.
//

import SwiftUI

@main
struct financial_appApp: App {
    @StateObject private var appCoordinator = AppCoordinator()
    var body: some Scene {
        WindowGroup {
            appCoordinator.contentView
                .environmentObject(appCoordinator)
        }
    }
}
