//
//  MonthYear.swift
//  financial_app
//
//  Created by Heelin Mistry on 2025/12/27.
//

import Foundation

// MARK: - MonthYear Model

struct MonthYear: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let monthKey: String // e.g., "2025-12"
    let displayName: String // e.g., "December 2025"
}
