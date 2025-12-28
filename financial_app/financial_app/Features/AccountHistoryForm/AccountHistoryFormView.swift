//
//  AccountHistoryFormView.swift
//  financial_app
//
//  Created by Heelin Mistry on 2025/12/27.
//
//
//  AccountHistoryFormView.swift
//  financial_app
//

import SwiftUI

struct AccountHistoryFormView: View {
    
    @StateObject var viewModel: AccountHistoryFormViewModel
    
    // Internal state for the DatePicker (Date binding is required)
    @State private var dateSelection: Date
    
    // Helper formatter for the DatePicker label
    private static let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    init(viewModel: AccountHistoryFormViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        
        // Convert the initial selectedMonth (if present) into a Date for the picker
        if let monthKey = viewModel.selectedMonth?.monthKey,
           let initialDate = AccountHistoryFormView.monthKeyToDate(monthKey) {
            self._dateSelection = State(initialValue: initialDate)
        } else {
            // Default to the current date if no history is selected
            self._dateSelection = State(initialValue: Date())
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account History")) {
                    Text("Select Month to update")
                        .font(.headline)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(viewModel.availableMonths) { monthYear in
                                Button {
                                    // 1. Update the ViewModel's selection
                                    viewModel.selectedMonthYear = monthYear
                                    // 2. Trigger the dependent history update logic
                                    viewModel.updateSelectedMonth(with: monthYear)
                                } label: {
                                    HStack(spacing: 6) {
                                        if viewModel.historyExists(for: monthYear) {
                                            Circle()
                                                .fill(Color.green) // Green for Stored History
                                                .frame(width: 8, height: 8)
                                                .offset(x: -2) // Nudge it left slightly
                                        }
                                        Text(monthYear.displayName)
                                    }
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(
                                                // Highlight if selected
                                                monthYear == viewModel.selectedMonthYear
                                                    ? Color.blue
                                                    : Color(.systemGray5)
                                                )
                                        )
                                        .foregroundColor(
                                            monthYear == viewModel.selectedMonthYear
                                            ? .white
                                            : Color(.label)
                                        )
                                }
                                .buttonStyle(.plain) // Use .plain to remove button default effects
                            }
                        }
                        .padding(.vertical, 4) // Slight padding for the scroll view edge
                        .padding(.horizontal, 16)
                    }
                    // Adjust horizontal position if needed
                    .padding(.horizontal, -16)
                    VStack(alignment: .leading, spacing: 20) {
                        CurrencyInputField(title: "Opening Balance", amountString: $viewModel.openingBalanceString)
                        CurrencyInputField(title: "Monthly Contribution", amountString: $viewModel.contributionString)
                        CurrencyInputField(title: "Closing Balance", amountString: $viewModel.closingBalanceString)
                        CurrencyInputField(title: "Exchange Rate", amountString: $viewModel.exchangeRateString)
                        if viewModel.isLoanAccountType {
                            CurrencyInputField(title: "Interest Rate", amountString: $viewModel.interestRateString)
                            CurrencyInputField(title: "Terms Left", amountString: $viewModel.termsLeftString)
                        }
                        // NOTE: You can add interest rate and terms left here for .LOAN type accounts
                    }
                    .padding(.horizontal)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(viewModel.saveButtonText) {
                        viewModel.updateAccountMonthHistory()
                    }
                    .font(.headline)
                    .padding()
                    .background(viewModel.isSaveButtonDisabled ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .disabled(viewModel.isSaveButtonDisabled || viewModel.isLoading)
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private static func monthKeyToDate(_ monthKey: String) -> Date? {
        // Assuming monthKey format is "yyyy-MM" (e.g., "2025-12")
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.date(from: monthKey)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        // Use your appropriate locale
        formatter.locale = Locale(identifier: "en_ZA")
        return formatter.string(from: NSNumber(value: value)) ?? "N/A"
    }
    
    // MARK: - Reusable Currency Input Field Component
    
    struct CurrencyInputField: View {
        let title: String
        @Binding var amountString: String
        
        var body: some View {
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                TextField("0.00", text: $amountString)
                    .keyboardType(.decimalPad) // Essential for currency input
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                // Optional: Force text alignment to the right
                    .multilineTextAlignment(.trailing)
            }
        }
    }
}
