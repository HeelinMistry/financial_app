//
//  AccountSummaryRow.swift
//  financial_app
//
//  Created by Heelin Mistry on 2025/12/26.
//

import SwiftUI

struct AccountSummaryRow: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    @StateObject var viewModel: AccountSummaryRowViewModel
    init(viewModel: AccountSummaryRowViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    private var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        // Assuming Rands (ZAR) based on the data structure,
        // adjust as needed for your specific currency
        formatter.locale = Locale(identifier: "en_ZA")
        return formatter
    }
    
    var body: some View {
        // Use DisclosureGroup to collapse/expand the monthly history
        DisclosureGroup {
            VStack(alignment: .leading, spacing: 8) {
                // History List
                ForEach(viewModel.account.monthlyHistory.reversed()) { history in
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Month: \(history.monthKey)")
                                .font(.caption).bold()
                            Spacer()
                            Text("Closing: \(currencyFormatter.string(from: NSNumber(value: history.closingBalance ?? 0.0)) ?? "N/A")")
                                .font(.caption)
                        }
                        if viewModel.account.type == .LOAN {
                            HStack {
                                Text("Rate: \(history.interestRate.map { String($0) + "%" } ?? "N/A")")
                                Text("Terms Left: \(history.termsLeft.map { String($0) } ?? "N/A")")
                            }
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding(.leading, 10)
        } label: {
            // Summary Header
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(viewModel.account.name).font(.headline)
                    Spacer()
                    // Display the latest closing balance
                    Text(currencyFormatter.string(from: NSNumber(value: viewModel.latestConvertedBalance)) ?? "N/A")
                        .font(.title3).fontWeight(.semibold)
                }
                Text("Type: \(viewModel.account.type.rawValue)")
                    .font(.subheadline)
                    .foregroundColor(viewModel.account.type == .LOAN ? .red : .green)
            }
            .padding(.vertical, 5)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            
            // 1. DELETE ACTION (Standard Red)
            Button(role: .destructive) {
                appCoordinator.presentConfirmationAlert(
                    title: "Confirm Delete",
                    message: "Are you sure you want to delete the account '\(viewModel.account.name)'?",
                    confirmTitle: "Delete",
                    confirmRole: .destructive,
                    confirmAction: {
                        viewModel.deleteAccount()
                    }
                )
            } label: {
                Label("Delete", systemImage: "trash.fill")
            }
            
            // 2. EDIT/UPDATE ACTION (Standard Accent/Blue)
            Button {
                viewModel.editAccount()
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue) // Set a distinct accent color
        }
    }
}
