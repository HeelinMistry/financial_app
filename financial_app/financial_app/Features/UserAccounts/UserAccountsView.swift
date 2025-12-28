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
                } else {
                    List {
                        ForEach(viewModel.accounts) { account in
                            AccountSummaryRow(viewModel: .init(account: account, coordinator: appCoordinator))
                        }
                    }
                }
            }
            .onAppear() {
                viewModel.fetchUserAccounts()
            }
            .navigationTitle("Your Accounts")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showAddAccounts()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .imageScale(.large)
                    }
                }
            }
            .navigationDestination(for: Destination.self) { destination in
                // Safely access the coordinator via the helper binding
                appCoordinator.view(for: destination)
            }
        }
    }
}
