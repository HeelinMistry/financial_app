//
//  Account.swift
//  financial_app
//
//  Created by Heelin Mistry on 2025/12/24.
//

struct Account: Identifiable, Decodable, Hashable, Sendable {
    let id: Int // The account ID
    let ownerId: String
    let name: String
    let type: String // e.g., "SAVING", "LOAN"
    let monthlyHistory: [MonthlyHistory]
}
