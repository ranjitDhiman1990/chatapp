//
//  AuthViewModel.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 23/04/25.
//


import AuthenticationServices

final class AuthViewModel: BaseViewModel {
    @Published private(set) var state: AuthState = .idle

    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
        super.init()
        self.checkCurrentUser()
    }
    
    func checkCurrentUser() {
        if let user = authService.currentUser() {
            state = .authenticated(user)
        } else {
            state = .unauthenticated
        }
    }
    
    @MainActor
    func verifyPhoneNumber(phoneNumber: String) async throws {
        do {
            let verificationId = try await authService.verifyPhoneNumber(phoneNumber: phoneNumber)
            state = .needsPhoneVerification(phoneNumber: phoneNumber, verificationId: verificationId)
        } catch {
            throw error
        }
    }
    
    @MainActor
    func signInWithPhoneNumber(verificationId: String, code: String) async throws {
        do {
            let user = try await authService.signInWithVerificationId(verificationId, code: code)
            state = .authenticated(user)
        } catch {
            throw error
        }
    }
    
    @MainActor
    func signInWithGoogle() async throws {
        do {
            let user = try await authService.signInWithGoogle()
            state = .authenticated(user)
        } catch {
           throw error
        }
    }
    
    @MainActor
    func signInWithApple() async throws {
        do {
            let user = try await authService.signInWithApple()
            state = .authenticated(user)
        } catch {
            throw error
        }
    }
    
    @MainActor
    func handleAppleAuthorization(credential: ASAuthorizationAppleIDCredential) async throws {
        do {
            let user = try await authService.handleAuthorization(credential: credential)
            state = .authenticated(user)
        } catch {
            throw error
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
    }
}
