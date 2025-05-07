//
//  OTPView.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 24/04/25.
//

import SwiftUI

public struct OTPView: View {
    @State var verificationCode: String
    @State var phoneNumber: String
    @State private var isLoading: Bool = false
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel: OTPViewModel = OTPViewModel()
    @FocusState private var focusedField: Int?
    
    
    init(phoneNumber: String, verificationID: String) {
        self.phoneNumber = phoneNumber
        self.verificationCode = verificationID
    }
    
    public var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                Text("Verification code")
                    .font(.title.bold())
                
                HStack(spacing: 10) {
                    ForEach(0..<6, id: \.self) { index in
                        OTPTextField(
                            digit: $viewModel.otp[index],
                            isFocused: focusedField == index,
                            onCommit: {
                                if index < 5 {
                                    focusedField = index + 1
                                } else {
                                    submitCode()
                                }
                            },
                            onBackspace: {
                                if index > 0 {
                                    focusedField = index - 1
                                }
                            }
                        )
                        .focused($focusedField, equals: index)
                    }
                }
                .padding(.horizontal)
                .onAppear {
                    focusedField = 0
                }
                
                PrimaryButton(text: "Verify Code") {
                    submitCode()
                }
                
                if viewModel.resendOtpCount > 0 {
                    Group {
                        Text("Resend code ")
                            .foregroundColor(.secondaryText)
                        + Text("00:\(String(format: "%02d", viewModel.resendOtpCount))")
                            .foregroundColor(.primaryText)
                    }
                } else {
                    VStack(spacing: 0) {
                        Button("Resend Code ?") {
                            isLoading = true
                            Task {
                                defer {
                                    isLoading = false
                                }
                                
                                do {
                                    try await authViewModel.verifyPhoneNumber(phoneNumber: phoneNumber)
                                } catch {
                                    debugPrint("verifyPhoneNumber error = \(error.localizedDescription)")
                                    viewModel.showToastForError(errorMessage: error.localizedDescription)
                                }
                            }
                        }
                        .font(.caption)
                        .foregroundStyle(.primary)
                        .padding(.top, -10)
                        
                        Divider()
                            .frame(height: 1)
                            .background(.appPrimary)
                    }
                    .fixedSize(horizontal: true, vertical: false)
                }
            }
            .padding(.top, -50)
            .padding(.horizontal, 16)
            .alertView.alert(isPresented: $viewModel.showAlert, alertStruct: viewModel.alert)
            .toastView(toast: $viewModel.toast)
            .onAppear {
                focusedField = 0
            }
        }
        .overlay(LoaderView(isLoading: isLoading))
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavbarBackButton()
            }
        }
    }
    
    private func submitCode() {
        if viewModel.validateForm() {
            let otpCode = viewModel.otp.map { String($0 ?? "") }.joined()
            isLoading = true
            Task {
                defer {
                    isLoading = false
                }
                
                do {
                    try await authViewModel.signInWithPhoneNumber(verificationId: verificationCode, code: otpCode)
                } catch {
                    debugPrint("signInWithPhoneNumber login error = \(error.localizedDescription)")
                    viewModel.showToastForError(errorMessage: error.localizedDescription)
                }
            }
        }
    }
}

struct OTPTextField: View {
    @Binding var digit: String?
    var isFocused: Bool
    var onCommit: () -> Void
    var onBackspace: (() -> Void)?
    
    @State private var text: String = ""
    
    var body: some View {
        TextField("", text: $text)
            .frame(maxWidth: 50, maxHeight: 40)
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isFocused ? Color.appPrimary : Color.disableText.opacity(0.4), lineWidth: 1)
            )
            .onChange(of: text) { newValue in
                if newValue.count > 1 {
                    // If user pastes multiple characters, take only the first one
                    text = String(newValue.prefix(1))
                    digit = text
                    onCommit()
                } else if newValue.count == 1 {
                    // Normal digit entry
                    digit = text
                    onCommit()
                } else if newValue.isEmpty {
                    // Backspace pressed
                    digit = ""
                    onBackspace?()
                }
            }
            .onAppear {
                text = digit ?? ""
            }
    }
}
