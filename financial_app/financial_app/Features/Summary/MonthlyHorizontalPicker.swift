//
//  MonthlyHorizontalPicker.swift
//  financial_app
//
//  Created by Heelin Mistry on 2026/01/28.
//

import SwiftUI

struct MonthlyHorizontalPicker: View {
    @State private var selectedMonth: MonthYear?
    let months: [MonthYear]
    
    let onMonthSelected: (MonthYear) -> Void

    var body: some View {
        // 1. The "Remote Control" wrapper
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(months, id: \.self) { month in
                        Button {
                            // 1. Update the ViewModel's selection
                            selectedMonth = month
                            onMonthSelected(month)
                            // 2. Trigger the dependent history update logic
//                                    viewModel.updateSelectedMonth(with: monthYear)
                        } label: {
                            HStack(spacing: 6) {
//                                        if viewModel.historyExists(for: monthYear) {
//                                            Circle()
//                                                .fill(Color.green) // Green for Stored History
//                                                .frame(width: 8, height: 8)
//                                                .offset(x: -2) // Nudge it left slightly
//                                        }
                                Text(month.displayName)
                            }
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(
                                        // Highlight if selected
                                        month == selectedMonth
                                            ? Color.blue
                                            : Color(.systemGray5)
                                        )
                                )
                                .foregroundColor(
                                    month == selectedMonth
                                    ? .white
                                    : Color(.label)
                                )
                        }
                        .buttonStyle(.plain) // Use .plain to remove button default effects
                    }
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 16)
            }
            // 3. Listen for changes and scroll
            .onChange(of: selectedMonth, { oldValue, newSelection in
                guard let newSelection else { return }
                withAnimation(.easeInOut) {
                    proxy.scrollTo(newSelection, anchor: .center)
                }
            })
            .onAppear {
                // To scroll to the last item on first load:
                if let last = months.last {
                    selectedMonth = last
                    onMonthSelected(last)
                    proxy.scrollTo(last, anchor: .trailing)
                }
            }
        }
    }
}
