//
//  MockUserDefaultsManager.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 07/05/25.
//

@testable import chatappdemo
import Foundation

class MockUserDefaultsManager: UserDefaultsManagerProtocol {
    
    private var mockStorage: [String: Any] = [:]
    private var shouldThrowError: Bool = false
    private var mockError: UserDefaultsError = .encodingError(NSError(domain: "MockError", code: -1, userInfo: nil))
    
    func saveAuthUser(_ user: AuthUser) throws {
        if shouldThrowError {
            throw mockError
        }
        
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(user)
            mockStorage[Keys.authUser.rawValue] = data
            mockStorage[Keys.isLoggedIn.rawValue] = true
        } catch {
            throw UserDefaultsError.encodingError(error)
        }
    }
    
    func getAuthUser() -> AuthUser? {
        guard let data = mockStorage[Keys.authUser.rawValue] as? Data else {
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(AuthUser.self, from: data)
        } catch {
            return nil
        }
    }
    
    func deleteAuthUser() {
        mockStorage.removeValue(forKey: Keys.authUser.rawValue)
        mockStorage.removeValue(forKey: Keys.isLoggedIn.rawValue)
    }
    
    var isUserLoggedIn: Bool {
        return true
    }
}

extension MockUserDefaultsManager {
    func setShouldThrowError(_ shouldThrow: Bool, with error: UserDefaultsError? = nil) {
        shouldThrowError = shouldThrow
        if let error = error {
            mockError = error
        }
    }
    
    func clearMockStorage() {
        mockStorage.removeAll()
    }
}
