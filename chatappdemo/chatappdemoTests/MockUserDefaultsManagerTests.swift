//
//  AuthViewModelTests.swift
//  chatappdemoTests
//
//  Created by Dhiman Ranjit on 07/05/25.
//

import XCTest
@testable import chatappdemo

final class MockUserDefaultsManagerTests: XCTestCase {
    
    var mockManager: MockUserDefaultsManager!
    
    override func setUp() {
        super.setUp()
        mockManager = MockUserDefaultsManager()
    }
    
    func testSaveAuthUserSuccess() throws {
        let testUser = AuthUser(id: "123", email: "test@example.com", displayName: "Test")
        
        XCTAssertNoThrow(try mockManager.saveAuthUser(testUser))
        XCTAssertTrue(mockManager.isUserLoggedIn)
        XCTAssertNotNil(mockManager.getAuthUser())
    }
    
    func testSaveAuthUserFailure() {
        mockManager.setShouldThrowError(true)
        let testUser = AuthUser(id: "123", email: "test@example.com", displayName: "Test")
        
        XCTAssertThrowsError(try mockManager.saveAuthUser(testUser))
    }
    
    func testDeleteAuthUser() throws {
        let testUser = AuthUser(id: "123", email: "test@example.com", displayName: "Test")
        try mockManager.saveAuthUser(testUser)
        
        mockManager.deleteAuthUser()
        
        XCTAssertFalse(mockManager.isUserLoggedIn)
        XCTAssertNil(mockManager.getAuthUser())
    }
    
    func testIsUserLoggedIn() {
        XCTAssertFalse(mockManager.isUserLoggedIn)
        
        let testUser = AuthUser(id: "123", email: "test@example.com", displayName: "Test")
        try? mockManager.saveAuthUser(testUser)
        
        XCTAssertTrue(mockManager.isUserLoggedIn)
    }
    
}
