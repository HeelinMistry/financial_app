//
//  MockCoordinator.swift
//  financial_app
//
//  Created by Heelin Mistry on 2025/12/25.
//

import SwiftUI
import Combine

class MockCoordinator: Coordinator {
    
    var contentView: some View { Text("") }
    var lastDestination: Destination?

    init() {}
    
    func start() {}
    
    // Implementation of navigate method
    func navigate(to destination: Destination) {
        self.lastDestination = destination
    }
}
