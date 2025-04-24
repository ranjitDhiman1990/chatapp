//
//  PrimaryButton.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 24/04/25.
//

import SwiftUI

struct PrimaryButton: View {

    @StateObject var loaderModel: LoaderViewModel = .init()

    private let buttonHeight: CGFloat = 50

    private let text: String
    private var bgColor: Color
    private var textColor: Color
    private let isEnabled: Bool
    private let showLoader: Bool

    private let onClick: (() -> Void)?

    init(text: String, textColor: Color = .white, bgColor: Color = .appPrimary,
                isEnabled: Bool = true, showLoader: Bool = false, onClick: (() -> Void)? = nil) {
        self.text = text
        self.textColor = textColor
        self.bgColor = bgColor
        self.isEnabled = isEnabled
        self.showLoader = showLoader
        self.onClick = onClick
    }

    var body: some View {
        Button {
            if isEnabled && !showLoader {
                onClick?()
            }
        } label: {
            HStack(spacing: 5) {
                if showLoader {
                    ProgressView()
                        .scaleEffect(1, anchor: .center)
                        .progressViewStyle(CircularProgressViewStyle(tint: textColor))
                        .opacity(loaderModel.isStillLoading ? 1 : 0)
                        .frame(width: !loaderModel.isStillLoading ? 0 : nil)
                        .animation(.default, value: loaderModel.isStillLoading)
                        .onAppear(perform: loaderModel.onViewAppear)
                }

                Text(text)
                    .foregroundStyle(isEnabled ? textColor : textColor.opacity(0.6))
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 15)
            .minimumScaleFactor(0.5)
            .background(isEnabled ? bgColor : bgColor.opacity(0.6))
            .clipShape(Capsule())
        }
        .frame(minHeight: buttonHeight)
        .buttonStyle(.scale)
        .disabled(!isEnabled || showLoader)
        .opacity(showLoader ? 0.8 : 1)
    }
}

struct ButtonStyleTapGestureModifier: ViewModifier {

    let action: () -> Void

    public func body(content: Content) -> some View {
        Button(action: action) {
            content
                .contentShape(Rectangle())
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

public struct ScaleButtonStyle: ButtonStyle {
    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}

public extension ButtonStyle where Self == ScaleButtonStyle {
    static var scale: Self {
        return .init()
    }
}
