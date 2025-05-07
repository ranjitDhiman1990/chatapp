//
//  MockAuthService.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 07/05/25.
//

@testable import chatappdemo

import Foundation
import AuthenticationServices

class MockAuthService: AuthServiceProtocol {
    var success = true
    var mockVerificationId = "mock_verification_id"
    var mockAuthUser = AuthUser(
        id: "mock_uid",
        email: "mock@mail.com",
        phoneNumber: "+917250876456",
        displayName: "Mock User",
        photoURL: nil
    )
    
    var mockError: Error = NSError(domain: "MockAuthServiceError", code: -1, userInfo: nil)
    var currentUserToReturn: AuthUser? = AuthUser(
        id: "mock_uid",
        email: "mock@mail.com",
        phoneNumber: "+917250876456",
        displayName: "Mock User",
        photoURL: nil
    )
    
    func verifyPhoneNumber(phoneNumber: String) async throws -> String {
        if success {
            return mockVerificationId
        } else {
            throw mockError
        }
    }
    
    func signInWithVerificationId(_ verificationId: String, code: String) async throws -> AuthUser {
        if success {
            return mockAuthUser
        } else {
            throw mockError
        }
    }
    
    func signInWithGoogle() async throws -> AuthUser {
        if success {
            return mockAuthUser
        } else {
            throw mockError
        }
    }
    
    func signInWithApple() async throws -> AuthUser {
        if success {
            return mockAuthUser
        } else {
            throw mockError
        }
    }
    
    func handleAuthorization(credential: ASAuthorizationAppleIDCredential) async throws -> AuthUser {
        if success {
            return mockAuthUser
        } else {
            throw mockError
        }
    }
    
    func signOut() throws {
        if !success {
            throw mockError
        }
        currentUserToReturn = nil
    }
    
    func currentUser() -> AuthUser? {
        return currentUserToReturn
    }
}

extension MockAuthService {
    // MARK: - Helper methods for testing
    
    func setSuccess() {
        success = true
    }
    
    func setFailure(error: Error? = nil) {
        success = false
        if let error = error {
            mockError = error
        }
    }
    
    func updateMockUser(newUser: AuthUser? = nil) {
        mockAuthUser = mockAuthUser.copyWith(
            id: newUser?.id ?? mockAuthUser.id,
            email: newUser?.email ?? mockAuthUser.email,
            phoneNumber: newUser?.phoneNumber ?? mockAuthUser.phoneNumber,
            displayName: newUser?.displayName ?? mockAuthUser.displayName,
            photoURL: newUser?.photoURL ?? mockAuthUser.photoURL,
            status: newUser?.status ?? mockAuthUser.status,
            lastActive: newUser?.lastActive ?? mockAuthUser.lastActive,
            createdAt: newUser?.createdAt ?? mockAuthUser.createdAt
        )
        currentUserToReturn = mockAuthUser
    }
}

protocol AppleIDCredentialProtocol {
    var user: String { get }
    var email: String? { get }
    var fullName: PersonNameComponents? { get }
}

extension ASAuthorizationAppleIDCredential: AppleIDCredentialProtocol {}

struct MockAppleIDCredential: AppleIDCredentialProtocol {
    let user: String
    let email: String?
    let fullName: PersonNameComponents?
}
