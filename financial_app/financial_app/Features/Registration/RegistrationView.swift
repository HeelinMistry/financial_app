//
//  RegistrationView.swift
//  financial_app
//
//  Created by Heelin Mistry on 2025/12/25.
//

import SwiftUI

struct RegistrationView: View {
    
    @StateObject var viewModel: RegistrationViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account Details")) {
                    SecureField("User", text: $viewModel.user)
                }
                
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Button("Register") {
                        viewModel.registerUser()
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.isRegisterButtonDisabled ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
            .navigationTitle("New User Registration")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        // Call the method that delegates back to the coordinator
                        viewModel.closeRegistration()
                    }
                }
            }
        }
    }
}
