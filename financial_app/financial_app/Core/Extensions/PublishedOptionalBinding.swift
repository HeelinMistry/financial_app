//
//  PublishedOptionalBinding.swift
//  financial_app
//
//  Created by Heelin Mistry on 2025/12/24.
//

import SwiftUI
import Combine

extension Binding where Value == Destination? {
    // Converts the Binding<Destination?> into a Binding<DestinationWrapper?>
    // This allows .sheet(item: ...) to work by wrapping the value
    // into the required Identifiable type (DestinationWrapper).
    var asIdentifiable: Binding<DestinationWrapper?> {
        Binding<DestinationWrapper?>(
            get: {
                // When SwiftUI reads the value, wrap the Destination in a DestinationWrapper
                self.wrappedValue.map(DestinationWrapper.init)
            },
            set: { identifiableWrapper in
                // When SwiftUI sets the value (e.g., dismissing the sheet),
                // unwrap the DestinationWrapper back into the optional Destination
                self.wrappedValue = identifiableWrapper?.destination
            }
        )
    }
}
