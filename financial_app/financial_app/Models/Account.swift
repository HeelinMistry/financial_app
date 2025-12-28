//
//  Account.swift
//  financial_app
//
//  Created by Heelin Mistry on 2025/12/24.
//

struct Account: Identifiable, Decodable, Hashable, Sendable {
    let id: Int // The account ID
    let ownerId: Int
    let name: String
    let type: AccountType // e.g., "SAVING", "LOAN"
    let monthlyHistory: [MonthlyHistory]
}

public enum AccountType: String, Decodable, Hashable, Identifiable, CaseIterable {
    case SAVING
    case LOAN
    
    public var id: String { self.rawValue }
}
