//
//  AppState.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 24/04/25.
//

enum AuthState: Equatable {
    static func == (lhs: AuthState, rhs: AuthState) -> Bool {
        return lhs.id == rhs.id
    }
    
    case idle
    case authenticated(AuthUser)
    case unauthenticated
    case needsPhoneVerification(phoneNumber: String, verificationId: String)
    case error(Error)
    
    var id: String {
        switch self {
        case .idle:
            "idle"
        case .authenticated(_):
            "authenticated"
        case .unauthenticated:
            "unauthenticated"
        case .needsPhoneVerification(phoneNumber: _, verificationId: _):
            "needsPhoneVerification"
        case .error(_):
            "error"
        }
    }
}
