//
//  AuthError.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 24/04/25.
//

import FirebaseAuth

enum AuthError: Error {
    // MARK: - App-level Errors
    case noRootViewController
    case invalidClientID
    case noToken
    case signInError(Error)
    case invalidCredential
    case invalidNonce
    case tokenSerialization

    // MARK: - Firebase Auth Errors
    case network
    case userNotFound
    case wrongPassword
    case invalidEmail
    case emailAlreadyInUse
    case weakPassword
    case invalidVerificationCode
    case missingVerificationCode
    case sessionExpired
    case tooManyRequests
    case userDisabled
    case credentialAlreadyInUse
    case requiresRecentLogin
    case unknown(message: String)

    var localizedDescription: String {
        switch self {
        // App-level
        case .noRootViewController:
            return "Could not find root view controller."
        case .invalidClientID:
            return "Invalid Firebase client ID."
        case .noToken:
            return "No ID token received."
        case .signInError(let error):
            return "Sign-in failed: \(error.localizedDescription)"
        case .invalidCredential:
            return "Invalid Firebase credential."
        case .invalidNonce:
            return "Nonce generation failed or was tampered with."
        case .tokenSerialization:
            return "Failed to serialize token."

        // Firebase Auth
        case .network:
            return "Network error. Please check your internet connection."
        case .userNotFound:
            return "No user found with this information."
        case .wrongPassword:
            return "Incorrect password. Please try again."
        case .invalidEmail:
            return "Invalid email address."
        case .emailAlreadyInUse:
            return "This email is already associated with another account."
        case .weakPassword:
            return "Your password is too weak. Try something stronger."
        case .invalidVerificationCode:
            return "The verification code is invalid or expired. Please enter the correct code sent to your device."
        case .missingVerificationCode:
            return "Please enter the verification code."
        case .sessionExpired:
            return "Session expired. Please try again."
        case .tooManyRequests:
            return "Too many attempts. Please wait and try again later."
        case .userDisabled:
            return "This user account has been disabled."
        case .credentialAlreadyInUse:
            return "This credential is already associated with another user."
        case .requiresRecentLogin:
            return "Please reauthenticate to perform this action."
        case .unknown(let message):
            return message
        }
    }
}

