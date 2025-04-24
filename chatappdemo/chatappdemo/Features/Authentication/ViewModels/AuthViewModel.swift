//
//  AuthViewModel.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 23/04/25.
//

import Foundation
import AuthenticationServices

final class AuthViewModel: ObservableObject {
    @Published private(set) var state: AuthState = .idle
    @Published var phoneNumber: String = ""
    @Published var verificationCode: String = ""
    
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
        checkCurrentUser()
    }
    
    func checkCurrentUser() {
        if let user = authService.currentUser() {
            state = .authenticated(user)
        } else {
            state = .unauthenticated
        }
    }
    
    func verifyPhoneNumber() async {
        state = .loading
        do {
            let verificationId = try await authService.verifyPhoneNumber(phoneNumber: phoneNumber)
            state = .needsPhoneVerification(verificationId: verificationId, phoneNumber: phoneNumber)
        } catch {
            state = .error(error)
        }
    }
    
    func signInWithPhoneNumber(verificationId: String, code: String) async {
        state = .loading
        do {
            let user = try await authService.signInWithVerificationId(verificationId, code: code)
            state = .authenticated(user)
        } catch {
            state = .error(error)
        }
    }
    
    func signInWithGoogle() async {
        state = .loading
        do {
            let user = try await authService.signInWithGoogle()
            state = .authenticated(user)
        } catch {
            state = .error(error)
        }
    }
    
    func signInWithApple() async {
        state = .loading
        do {
            let user = try await authService.signInWithApple()
            state = .authenticated(user)
        } catch {
            state = .error(error)
        }
    }
    
    func handleAppleAuthorization(credential: ASAuthorizationAppleIDCredential) async {
        state = .loading
        do {
            let user = try await authService.handleAuthorization(credential: credential)
            state = .authenticated(user)
        } catch {
            state = .error(error)
        }
    }
    
    func signOut() {
        do {
            try authService.signOut()
            state = .unauthenticated
        } catch {
            state = .error(error)
        }
    }
    
    func reset() {
        state = .idle
        phoneNumber = ""
        verificationCode = ""
    }
}
