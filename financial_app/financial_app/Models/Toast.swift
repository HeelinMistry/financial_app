//
//  Toast.swift
//  financial_app
//
//  Created by Heelin Mistry on 2025/12/25.
//

import SwiftUI

struct Toast: Equatable, Identifiable {
    let id = UUID()
    var style: ToastStyle
    var message: String
    var duration: Double = 3.0 // Default duration
    
    // Defines the appearance of the toast
    enum ToastStyle {
        case success
        case failure
        case warning
        case info
    }
    
    var iconName: String {
        switch style {
        case .success: return "checkmark.circle.fill"
        case .failure: return "xmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        }
    }
    
    var themeColor: Color {
        switch style {
        case .success: return .green
        case .failure: return .red
        case .warning: return .orange
        case .info: return .blue
        }
    }
}
