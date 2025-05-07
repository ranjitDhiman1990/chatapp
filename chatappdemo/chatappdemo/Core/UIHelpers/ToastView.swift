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

public struct ToastViewSwiftUI: View {
    let toast: ToastView
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 12) {
                Image(systemName: toast.type.iconName)
                    .foregroundColor(toast.type.themeColor)
                
                VStack(alignment: .leading, spacing: 2) {
                    if !toast.title.isEmpty {
                        Text(toast.title)
                            .font(.headline)
                    }
                    
                    Text(toast.message)
                        .font(.subheadline)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(8)
            .shadow(radius: 4)
            .overlay(
                Rectangle()
                    .fill(toast.type.themeColor)
                    .frame(width: 6)
                    .clipped()
                , alignment: .leading
            )
        }
        .padding(.horizontal)
    }
}

struct ToastModifier: ViewModifier {
    @Binding var toast: ToastView?
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(
                Group {
                    if let toast = toast {
                        VStack {
                            ToastViewSwiftUI(toast: toast)
                                .padding()
                                .transition(.asymmetric(
                                    insertion: .move(edge: .top),
                                    removal: .opacity
                                ))
                                .animation(.spring(), value: toast)
                            
                            Spacer()
                        }
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration) {
                                withAnimation {
                                    self.toast?.onDismiss?()
                                    self.toast = nil
                                }
                            }
                        }
                    }
                }
            )
    }
}

extension View {
    func toastView(toast: Binding<ToastView?>) -> some View {
        self.modifier(ToastModifier(toast: toast))
    }
}
