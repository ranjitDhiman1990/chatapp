//
//  UserDefaultsManager.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 26/04/25.
//

import Foundation

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private let userDefaults = UserDefaults.standard
    
    private enum Keys: String {
        case authUser
        case isLoggedIn
    }
    
    // MARK: - AuthUser Management

    func saveAuthUser(_ user: AuthUser) throws {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(user)
            userDefaults.set(data, forKey: Keys.authUser.rawValue)
            userDefaults.set(true, forKey: Keys.isLoggedIn.rawValue)
        } catch {
            throw UserDefaultsError.encodingError(error)
        }
    }
    
    func getAuthUser() -> AuthUser? {
        guard let data = userDefaults.data(forKey: Keys.authUser.rawValue) else {
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(AuthUser.self, from: data)
        } catch {
            debugPrint("Failed to decode AuthUser: \(error)")
            return nil
        }
    }
    
    func deleteAuthUser() {
        userDefaults.removeObject(forKey: Keys.authUser.rawValue)
        userDefaults.set(false, forKey: Keys.isLoggedIn.rawValue)
    }
    
    var isUserLoggedIn: Bool {
        return userDefaults.bool(forKey: Keys.isLoggedIn.rawValue)
    }
}
