//
//  ErrorHandler.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 25/04/25.
//

import Foundation
import FirebaseAuth

class ErrorHandler {
    static func mapFirebaseError(_ error: Error) -> AuthError {
        let nsError = error as NSError
        guard nsError.domain == AuthErrorDomain,
              let code = AuthErrorCode(rawValue: nsError.code) else {
            return .signInError(error)
        }

        switch code {
        case .networkError: return .network
        case .userNotFound: return .userNotFound
        case .wrongPassword: return .wrongPassword
        case .invalidEmail: return .invalidEmail
        case .emailAlreadyInUse: return .emailAlreadyInUse
        case .weakPassword: return .weakPassword
        case .invalidVerificationCode: return .invalidVerificationCode
        case .missingVerificationCode: return .missingVerificationCode
        case .sessionExpired: return .sessionExpired
        case .tooManyRequests: return .tooManyRequests
        case .userDisabled: return .userDisabled
        case .invalidCredential: return .invalidCredential
        case .credentialAlreadyInUse: return .credentialAlreadyInUse
        case .requiresRecentLogin: return .requiresRecentLogin
        default:
            return .unknown(message: nsError.localizedDescription)
        }
    }
}
