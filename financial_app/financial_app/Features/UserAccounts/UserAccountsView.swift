//
//  UserAccountsView.swift
//  financial_app
//
//  Created by Heelin Mistry on 2025/12/24.
//

import SwiftUI

struct UserAccountsView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    @StateObject var viewModel: UserAccountsViewModel
    
    init(viewModel: UserAccountsViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack(path: $appCoordinator.navigationPath) {
            
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading Accounts...")
                } else if viewModel.accounts.isEmpty {
                    Text("No accounts found.")
                } else if let error = viewModel.errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                } else {
                    List {
                        ForEach(viewModel.accounts) { account in
                            AccountSummaryRow(account: account)
                        }
                    }
                }
            }
            .onAppear {
                viewModel.fetchUserAccounts()
            }
            .navigationTitle("Your Accounts")
            .navigationDestination(for: Destination.self) { destination in
                // Safely access the coordinator via the helper binding
                (viewModel.coordinator as? AppCoordinator)?.view(for: destination)
            }
        }
    }
}

// MARK: - Component Views

struct AccountSummaryRow: View {
    let account: Account
    
    // Determine the current or latest closing balance for display
    private var latestBalance: Double {
        account.monthlyHistory.last?.closingBalance ?? 0.0
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
                ForEach(account.monthlyHistory.reversed()) { history in
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Month: \(history.monthKey)")
                                .font(.caption).bold()
                            Spacer()
                            Text("Closing: \(currencyFormatter.string(from: NSNumber(value: history.closingBalance)) ?? "N/A")")
                                .font(.caption)
                        }
                        if account.type == "LOAN" {
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
                    Text(account.name).font(.headline)
                    Spacer()
                    // Display the latest closing balance
                    Text(currencyFormatter.string(from: NSNumber(value: latestBalance)) ?? "N/A")
                        .font(.title3).fontWeight(.semibold)
                }
                Text("Type: \(account.type)")
                    .font(.subheadline)
                    .foregroundColor(account.type == "LOAN" ? .red : .green)
            }
            .padding(.vertical, 5)
        }
    }
}
