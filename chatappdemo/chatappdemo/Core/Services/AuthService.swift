//
//  AuthService.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 23/04/25.
//

import GoogleSignIn
import FirebaseCore
import FirebaseAuth
import AuthenticationServices

protocol AuthServiceProtocol {
    func verifyPhoneNumber(phoneNumber: String) async throws -> String
    func signInWithVerificationId(_ verificationId: String, code: String) async throws -> AuthUser
    
    func signInWithGoogle() async throws -> AuthUser
    
    func signInWithApple() async throws -> AuthUser
    func handleAuthorization(credential: ASAuthorizationAppleIDCredential) async throws -> AuthUser
    
    func signOut() throws
    func currentUser() -> AuthUser?
}

public class AuthService: NSObject, AuthServiceProtocol {
    private var currentNonce: String?
    private weak var presentationAnchor: ASPresentationAnchor?
    private var continuation: CheckedContinuation<AuthUser, Error>?
    
    func verifyPhoneNumber(phoneNumber: String) async throws -> String {
        return try await FirebaseManager.phoneAuthProvider.verifyPhoneNumber(phoneNumber, uiDelegate: nil)
    }
    
    func signInWithVerificationId(_ verificationId: String, code: String) async throws -> AuthUser {
        let credential = FirebaseManager.phoneAuthProvider.credential(
            withVerificationID: verificationId,
            verificationCode: code
        )
        let result = try await FirebaseManager.auth.signIn(with: credential)
        return AuthUser(user: result.user)
    }
    
    func signInWithGoogle() async throws -> AuthUser {
        guard let clientId = FirebaseApp.app()?.options.clientID else {
            throw AuthError.invalidClientID
        }
        
        let config = GIDConfiguration(clientID: clientId)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene, let window = await windowScene.windows.first, let rootViewController = await window.rootViewController else {
            throw AuthError.noRootViewController
        }
        
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        let user = result.user
        guard let idToken = user.idToken?.tokenString else {
            throw AuthError.noToken
        }
        
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: user.accessToken.tokenString
        )
        
        let authResult = try await Auth.auth().signIn(with: credential)
        return AuthUser(user: authResult.user)
    }
    
    func signInWithApple() async throws -> AuthUser {
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            
            let nonce = NonceGenerator.randomNonceString()
            let hashedNonce = NonceGenerator.sha256(nonce)
            self.currentNonce = nonce
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = hashedNonce
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        }
    }
    
    func handleAuthorization(credential: ASAuthorizationAppleIDCredential) async throws -> AuthUser {
        guard let nonce = currentNonce else {
            throw AuthError.invalidNonce
        }
        
        guard let appleIDToken = credential.identityToken else {
            throw AuthError.noToken
        }
        
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            throw AuthError.tokenSerialization
        }
        
        let firebaseCredential = OAuthProvider.credential(
            providerID: AuthProviderID.apple,
            idToken: idTokenString,
            rawNonce: nonce
        )
        
        let result = try await Auth.auth().signIn(with: firebaseCredential)
        return AuthUser(user: result.user)
    }
    
    func signOut() throws {
        try FirebaseManager.auth.signOut()
    }
    
    func currentUser() -> AuthUser? {
        guard let user = FirebaseManager.auth.currentUser else { return nil }
        return AuthUser(user: user)
    }
}

extension AuthService: ASAuthorizationControllerDelegate {
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task {
            do {
                guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                    continuation?.resume(throwing: AuthError.invalidCredential)
                    return
                }
                
                let user = try await handleAuthorization(credential: appleIDCredential)
                continuation?.resume(returning: user)
            } catch {
                continuation?.resume(throwing: error)
            }
        }
    }
    
    public func authorizationController(controller: ASAuthorizationController,
                                        didCompleteWithError error: Error) {
        continuation?.resume(throwing: error)
    }
}

extension AuthService: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return presentationAnchor ?? UIApplication.shared.firstKeyWindow ?? UIWindow()
    }
}
