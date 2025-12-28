//
//  CreateAccount.swift
//  financial_app
//
//  Created by Heelin Mistry on 2025/12/26.
//

struct AccountDetails: Decodable, Hashable, Sendable {
    let name: String
    let type: AccountType // e.g., "SAVING", "LOAN"
}
