//
//  DoubleExtension.swift
//  financial_app
//
//  Created by Heelin Mistry on 2025/12/27.
//
import Foundation

extension Double {
    /// Rounds the double to the specified number of decimal places.
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
