//
//  AuthViewModelTests.swift
//  chatappdemoTests
//
//  Created by Dhiman Ranjit on 07/05/25.
//

import XCTest
import AuthenticationServices

@testable import chatappdemo

final class MockAuthServiceTests: XCTestCase {
    
    var mockAuthService: MockAuthService!
    let testPhoneNumber = "+1234567890"
    let testVerificationID = "testVerificationID"
    let testVerificationCode = "123456"
    let testEmail = "test@mail.com"
    
    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthService()
    }
    
    override func tearDown() {
        mockAuthService = nil
        super.tearDown()
    }
    
    // MARK: - Phone Authentication Tests
    
    func testVerifyPhoneNumberSuccess() async {
        // Given
        mockAuthService.setSuccess()
        mockAuthService.mockVerificationId = testVerificationID
        
        // When
        do {
            let verificationId = try await mockAuthService.verifyPhoneNumber(phoneNumber: testPhoneNumber)
            
            // Then
            XCTAssertEqual(verificationId, testVerificationID)
        } catch {
            XCTFail("Expected successful verification, but got error: \(error)")
        }
    }
    
    func testVerifyPhoneNumberFailure() async {
        // Given
        let expectedError = NSError(domain: "TestError", code: 500)
        mockAuthService.setFailure(error: expectedError)
        
        // When/Then
        do {
            _ = try await mockAuthService.verifyPhoneNumber(phoneNumber: testPhoneNumber)
            XCTFail("Expected error but verification succeeded")
        } catch {
            XCTAssertEqual(error as NSError, expectedError)
        }
    }
    
    func testSignInWithVerificationIdSuccess() async {
        // Given
        let expectedUser = AuthUser(id: "phone-user", email: nil, displayName: nil)
        mockAuthService.setSuccess()
        mockAuthService.mockAuthUser = expectedUser
        
        // When
        do {
            let user = try await mockAuthService.signInWithVerificationId(testVerificationID, code: testVerificationCode)
            
            // Then
            XCTAssertEqual(user.id, expectedUser.id)
        } catch {
            XCTFail("Expected successful sign in, but got error: \(error)")
        }
    }
    
    // MARK: - Google Authentication Tests
    
    func testSignInWithGoogleSuccess() async {
        // Given
        let expectedUser = AuthUser(id: "google-user", email: "google@test.com", displayName: "Google User")
        mockAuthService.setSuccess()
        mockAuthService.mockAuthUser = expectedUser
        
        // When
        do {
            let user = try await mockAuthService.signInWithGoogle()
            
            // Then
            XCTAssertEqual(user.id, expectedUser.id)
            XCTAssertEqual(user.email, expectedUser.email)
            XCTAssertEqual(user.displayName, expectedUser.displayName)
        } catch {
            XCTFail("Expected successful Google sign in, but got error: \(error)")
        }
    }
    
    // MARK: - Apple Authentication Tests
    
    func testSignInWithAppleSuccess() async {
        // Given
        let expectedUser = AuthUser(id: "apple-user", email: "apple@test.com", displayName: "Apple User")
        mockAuthService.setSuccess()
        mockAuthService.mockAuthUser = expectedUser
        
        // When
        do {
            let user = try await mockAuthService.signInWithApple()
            
            // Then
            XCTAssertEqual(user.id, expectedUser.id)
        } catch {
            XCTFail("Expected successful Apple sign in, but got error: \(error)")
        }
    }
    
    // MARK: - Session Management Tests
    
    func testSignOutSuccess() {
        // Given
        mockAuthService.setSuccess()
        mockAuthService.currentUserToReturn = AuthUser(id: "test", email: nil, displayName: nil)
        
        // When
        XCTAssertNoThrow(try mockAuthService.signOut())
        
        // Then
        XCTAssertNil(mockAuthService.currentUser())
    }
    
    func testSignOutFailure() {
        // Given
        let expectedError = NSError(domain: "SignOutError", code: 401)
        mockAuthService.setFailure(error: expectedError)
        
        // When/Then
        XCTAssertThrowsError(try mockAuthService.signOut()) { error in
            XCTAssertEqual(error as NSError, expectedError)
        }
    }
    
    func testCurrentUserWhenLoggedIn() {
        // Given
        let expectedUser = AuthUser(id: "current-user", email: nil, displayName: nil)
        mockAuthService.currentUserToReturn = expectedUser
        
        // When
        let user = mockAuthService.currentUser()
        
        // Then
        XCTAssertEqual(user?.id, expectedUser.id)
    }
    
    func testCurrentUserWhenLoggedOut() {
        // Given
        mockAuthService.currentUserToReturn = nil
        
        // When
        let user = mockAuthService.currentUser()
        
        // Then
        XCTAssertNil(user)
    }
    
    // MARK: - Apple Credential Handling Tests
    
//    func testHandleAuthorizationSuccess() async {
//        let expectedUser = AuthUser(id: "apple-credential-user",
//                                    email: "credential@test.com",
//                                    displayName: "Test User")
//        mockAuthService.setSuccess()
//        mockAuthService.mockAuthUser = expectedUser
//        
//        let credential = MockAppleIDCredential(
//            user: "appleUserID",
//            email: "credential@test.com",
//            fullName: PersonNameComponents(givenName: "Test", familyName: "User")
//        )
//        
//        // When/Then remains the same
//        do {
//            let user = try await mockAuthService.handleAuthorization(credential: credential)
//            XCTAssertEqual(user.id, expectedUser.id)
//        } catch {
//            XCTFail("Unexpected error: \(error)")
//        }
//    }
    
    func testMockConfiguration() {
        // Test that mock configuration works properly
        let testUser1 = AuthUser(id: "user1", email: nil, displayName: nil)
        let testUser2 = AuthUser(id: "user2", email: nil, displayName: nil)
        
        // Verify initial state
        XCTAssertTrue(mockAuthService.success)
        
        // Configure for failure
        mockAuthService.setFailure()
        XCTAssertFalse(mockAuthService.success)
        
        // Configure custom user
        mockAuthService.mockAuthUser = testUser1
        mockAuthService.currentUserToReturn = testUser2
        
        XCTAssertEqual(mockAuthService.mockAuthUser.id, "user1")
        XCTAssertEqual(mockAuthService.currentUser()?.id, "user2")
    }
}
