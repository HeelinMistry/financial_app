//
//  LoginView.swift
//  financial_app
//
//  Created by Heelin Mistry on 2025/12/24.
//

import SwiftUI

struct LoginView: View {
    
    @StateObject var viewModel: LoginViewModel
    init(viewModel: LoginViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                // --- Input Fields ---
                SecureField("User", text: $viewModel.user)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                
                // --- Loading and Error Status ---
                if viewModel.isLoading {
                    ProgressView()
                }
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.top, 5)
                }
                
                // --- Login Button ---
                Button(action: viewModel.login) {
                    Text("Log In")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isLoginButtonDisabled ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(viewModel.isLoginButtonDisabled)
                
                Spacer()
            }
            .padding()
            .navigationTitle("User Login")
        }
    }
}
