//
//  AccountFormView.swift
//  financial_app
//
//  Created by Heelin Mistry on 2025/12/26.
//

import SwiftUI

struct AccountFormView: View {
    
    @StateObject var viewModel: AccountFormViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account Details")) {
                    TextField("Account Name", text: $viewModel.name)
                    Picker("Account Type", selection: $viewModel.type) {
                        ForEach(AccountType.allCases) { type in
                            // Use the rawValue (e.g., "Savings Account") for display
                            Text(type.rawValue)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 8)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.addAccount()
                    }
                    .font(.headline)
                    .padding()
                    .background(viewModel.isSaveButtonDisabled ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
        }
    }
}
