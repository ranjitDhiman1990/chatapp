//
//  AppState.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 24/04/25.
//

enum AuthState {
    case idle
    case loading
    case authenticated(AuthUser)
    case unauthenticated
    case needsPhoneVerification(verificationId: String, phoneNumber: String)
    case error(Error)
}
