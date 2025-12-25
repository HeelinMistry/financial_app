//
//  MonthlyHistory.swift
//  financial_app
//
//  Created by Heelin Mistry on 2025/12/24.
//

struct MonthlyHistory: Identifiable, Decodable, Hashable {
    // We create a composite ID for monthly history for SwiftUI ForEach loops
    var id: String { monthKey }
    
    let monthKey: String
    let openingBalance: Double
    let contribution: Double
    let closingBalance: Double
    let exchangeRate: Double
    // Only present for LOAN accounts
    let interestRate: Double?
    let termsLeft: Int?
    
    // Use CodingKeys to handle optional properties gracefully
    private enum CodingKeys: String, CodingKey {
        case monthKey, openingBalance, contribution, closingBalance, exchangeRate
        case interestRate, termsLeft
    }
    
    init(monthKey: String, openingBalance: Double, contribution: Double, closingBalance: Double, exchangeRate: Double, interestRate: Double? = nil, termsLeft: Int? = nil) {
        self.monthKey = monthKey
        self.openingBalance = openingBalance
        self.contribution = contribution
        self.closingBalance = closingBalance
        self.exchangeRate = exchangeRate
        self.interestRate = interestRate
        self.termsLeft = termsLeft
    }
}
