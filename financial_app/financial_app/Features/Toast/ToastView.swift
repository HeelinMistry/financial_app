//
//  ToastView.swift
//  financial_app
//
//  Created by Heelin Mistry on 2025/12/25.
//

import SwiftUI

struct ToastView: View {
    let toast: Toast
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: toast.iconName)
                .foregroundColor(toast.themeColor)
            
            Text(toast.message)
                .font(.subheadline)
                .foregroundColor(.black)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
        .background(
            Capsule()
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 3)
        )
        .padding(.top, 50) // Pushed down from the top edge
    }
}
