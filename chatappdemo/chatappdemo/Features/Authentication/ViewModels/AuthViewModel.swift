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
    
    func getCurrentUser() -> AuthUser? {
        if let user = authService.currentUser() {
            if let userData = UserDefaultsManager.shared.getAuthUser() {
                return userData
            } else {
                return user
            }
        }
        return nil
    }
    
    func checkCurrentUser() {
        if let user = authService.currentUser() {
            if let userData = UserDefaultsManager.shared.getAuthUser() {
                state = .authenticated(userData)
            } else {
                state = .incompleteProfile(user)
            }
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
        var user: AuthUser? = nil
        do {
            user = try await authService.signInWithVerificationId(verificationId, code: code)
            if user == nil {
                throw AuthError.unknown(message: "Something went wrong, please try again later.")
            }
            if let userData = try await UserService.shared.read(id: user!.id) {
                state = .authenticated(userData)
                try UserDefaultsManager.shared.saveAuthUser(userData)
            } else {
                state = .incompleteProfile(user!)
            }
        } catch {
            if user != nil {
                state = .incompleteProfile(user!)
            }
            throw error
        }
    }
    
    @MainActor
    func signInWithGoogle() async throws {
        var user: AuthUser? = nil
        do {
            user = try await authService.signInWithGoogle()
            if user == nil {
                throw AuthError.unknown(message: "Something went wrong, please try again later.")
            }
            if let userData = try await UserService.shared.read(id: user!.id) {
                state = .authenticated(userData)
                try UserDefaultsManager.shared.saveAuthUser(userData)
            } else {
                state = .incompleteProfile(user!)
            }
        } catch {
            if user != nil {
                state = .incompleteProfile(user!)
            }
            throw error
        }
    }
    
    @MainActor
    func signInWithApple() async throws {
        var user: AuthUser? = nil
        do {
            user = try await authService.signInWithApple()
            if user == nil {
                throw AuthError.unknown(message: "Something went wrong, please try again later.")
            }
            if let userData = try await UserService.shared.read(id: user!.id) {
                state = .authenticated(userData)
                try UserDefaultsManager.shared.saveAuthUser(userData)
            } else {
                state = .incompleteProfile(user!)
            }
        } catch {
            if user != nil {
                state = .incompleteProfile(user!)
            }
            throw error
        }
    }
    
    @MainActor
    func handleAppleAuthorization(credential: ASAuthorizationAppleIDCredential) async throws {
        var user: AuthUser? = nil
        do {
            user = try await authService.handleAuthorization(credential: credential)
            if user == nil {
                throw AuthError.unknown(message: "Something went wrong, please try again later.")
            }
            if let userData = try await UserService.shared.read(id: user!.id) {
                state = .authenticated(userData)
                try UserDefaultsManager.shared.saveAuthUser(userData)
            } else {
                state = .incompleteProfile(user!)
            }
        } catch {
            if user != nil {
                state = .incompleteProfile(user!)
            }
            throw error
        }
    }
    
    func createUserInFireStoreDB(user: AuthUser) async throws {
        do {
            try await UserService.shared.create(user)
            state = .authenticated(user)
            try UserDefaultsManager.shared.saveAuthUser(user)
        } catch {
            throw error
        }
    }
    
    func updateUserInFireStoreDB(user: AuthUser) async throws {
        do {
            try await UserService.shared.update(user)
            state = .authenticated(user)
            try UserDefaultsManager.shared.saveAuthUser(user)
        } catch {
            throw error
        }
    }
    
    func signOut() {
        do {
            try authService.signOut()
            UserDefaultsManager.shared.deleteAuthUser()
            state = .unauthenticated
        } catch {
            state = .error(error)
        }
    }
    
    func reset() {
        state = .idle
    }
}
