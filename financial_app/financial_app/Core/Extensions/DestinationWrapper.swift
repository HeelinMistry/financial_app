//
//  DestinationWrapper.swift
//  financial_app
//
//  Created by Heelin Mistry on 2025/12/24.
//

import Foundation

// Used to make the Optional Destination enum conform to Identifiable for .sheet/modal
struct DestinationWrapper: Identifiable {
    let id = UUID() // Standard identifiable requirement
    let destination: Destination
}
