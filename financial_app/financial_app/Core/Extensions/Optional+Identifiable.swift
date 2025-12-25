//
//  Optional+Identifiable.swift
//  financial_app
//
//  Created by Heelin Mistry on 2025/12/24.
//

import SwiftUI

// Allows an Optional Enum (like Destination) to be used with .sheet(item:)
extension Optional where Wrapped == Destination {
    var asIdentifiable: DestinationWrapper? {
        get { self.map(DestinationWrapper.init) }
        set { self = newValue?.destination }
    }
}
