//
//  AuthViewModel.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 23/04/25.
//

import Foundation
import AuthenticationServices

final class AuthViewModel: BaseViewModel {
    @Published private(set) var state: AuthState = .idle
    @Published var phoneNumber: String = ""
    @Published var verificationCode: String = ""
    private(set) var showLoader: Bool = false
    var otp = ""
    var resendOtpCount: Int = 30
    var countries: [Country]
    var currentCountry: Country
    
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
        let allCountries = JSONReader.readJSONFromFile(fileName: "Countries", type: [Country].self) ?? []
        var currentLocal = ""
        if #available(iOS 16, *) {
            currentLocal = Locale.current.region?.identifier ?? "IN"
        } else {
            currentLocal = Locale.current.identifier
        }
        self.countries = allCountries
        self.currentCountry = allCountries.first(where: {$0.isoCode == currentLocal}) ?? (allCountries.first ?? Country(name: "India", dialCode: "+91", isoCode: "IN"))
        
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
    func verifyPhoneNumber() async {
        state = .loading
        do {
            let verificationId = try await authService.verifyPhoneNumber(phoneNumber: phoneNumber)
            state = .needsPhoneVerification(verificationId: verificationId, phoneNumber: phoneNumber)
        } catch {
            state = .error(error)
        }
    }
    
    @MainActor
    func signInWithPhoneNumber(verificationId: String, code: String) async {
        state = .loading
        do {
            let user = try await authService.signInWithVerificationId(verificationId, code: code)
            state = .authenticated(user)
        } catch {
            state = .error(error)
        }
    }
    
    @MainActor
    func signInWithGoogle() async {
        state = .loading
        do {
            let user = try await authService.signInWithGoogle()
            state = .authenticated(user)
        } catch {
            state = .error(error)
        }
    }
    
    @MainActor
    func signInWithApple() async {
        state = .loading
        do {
            let user = try await authService.signInWithApple()
            state = .authenticated(user)
        } catch {
            state = .error(error)
        }
    }
    
    @MainActor
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
            reset()
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
