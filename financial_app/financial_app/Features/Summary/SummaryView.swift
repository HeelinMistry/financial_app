//
//  SummaryView.swift
//  financial_app
//
//  Created by Heelin Mistry on 2026/01/28.
//

import SwiftUI

struct SummaryView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    @StateObject var viewModel: SummaryViewModel
    
    init(viewModel: SummaryViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack(path: $appCoordinator.navigationPath) {
            VStack(spacing: 12) {
                if viewModel.isLoading {
                    ProgressView("Loading Accounts...")
                        .padding(.top, 24)
                } else if viewModel.accounts.isEmpty {
                    Text("No accounts found.")
                        .foregroundStyle(.secondary)
                        .padding(.top, 24)
                } else {
                    // Month selector
                    MonthlyHorizontalPicker(
                        months: viewModel.availableMonths,
                        onMonthSelected: { selectedMonthYear in
                            viewModel.selectedMonthYear = selectedMonthYear
                        }
                    )
                    .padding(.bottom, 8)
                    
                    // Filtered accounts list
                    if viewModel.filteredAccountsBySelectedMonth.isEmpty {
                        VStack(spacing: 8) {
                            Text("No data for the selected month")
                                .font(.headline)
                            if let monthName = viewModel.selectedMonthYear?.displayName {
                                Text("Try another month: \(monthName) has no entries.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.top, 24)
                        .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        VStack {
                            Text("Total Closing: \(viewModel.totalClosing.formatted(.currency(code: "ZAR")))")
                                .font(.caption).bold()
                            Text("Total Contribution: \(viewModel.totalContribution.formatted(.currency(code: "ZAR")))")
                                .font(.caption).bold()
                            Text("Total PnL: \(viewModel.totalPnL.formatted(.currency(code: "ZAR")))")
                                .font(.caption).bold()
                        }
                    }
                }
                Spacer()
            }
            .onAppear {
                viewModel.fetchUserAccounts()
            }
            .navigationTitle("Summary")
            .navigationDestination(for: Destination.self) { destination in
                appCoordinator.view(for: destination)
            }
        }
    }
}
