//
//  AuthError.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 24/04/25.
//

enum AuthError: Error {
    case noRootViewController
    case invalidClientID
    case noToken
    case signInError(Error)
    case invalidCredential
    case invalidNonce
    case tokenSerialization
    
    var localizedDescription: String {
        switch self {
        case .noRootViewController:
            return "Could not find root view controller"
        case .invalidClientID:
            return "Invalid Firebase client ID"
        case .noToken:
            return "No ID token from Google"
        case .signInError(let error):
            return "Google sign in failed: \(error.localizedDescription)"
        case .invalidCredential:
            return "Invalid firebase credential"
        case .invalidNonce:
            return "Invalid nonce generated"
        case .tokenSerialization:
            return "Token serialization error"
        }
    }
}
