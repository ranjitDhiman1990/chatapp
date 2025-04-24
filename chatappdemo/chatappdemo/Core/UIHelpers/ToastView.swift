//
//  ToastView.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 24/04/25.
//

import SwiftUI

public enum ToastStyle {
    case error
    case warning
    case success
    case info
}

public extension ToastStyle {
    var themeColor: Color {
        switch self {
        case .error: return Color.red
        case .warning: return Color.orange
        case .info: return Color.blue
        case .success: return Color.green
        }
    }

    var iconName: String {
        switch self {
        case .info: return "info.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        }
    }
}

public struct ToastView: Equatable {

    public static func == (lhs: ToastView, rhs: ToastView) -> Bool {
        return lhs.type == rhs.type && lhs.title == rhs.title && lhs.message == rhs.message && lhs.duration == rhs.duration
    }

    public let type: ToastStyle
    public let title: String
    public let message: String
    public let duration: Double
    public let onDismiss: (() -> Void)?

    public init(type: ToastStyle, title: String, message: String, duration: Double = 3, onDismiss: (() -> Void)? = nil) {
        self.type = type
        self.title = title
        self.message = message
        self.duration = duration
        self.onDismiss = onDismiss
    }
}
