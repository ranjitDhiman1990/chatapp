//
//  AppPreference.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 24/04/25.
//

import Foundation

actor AppPreference {

    enum Key: String {
        case isVerifiedUser = "is_verified_user"
        case user           = "user"
    }

    init() { }

    func getIsVerifiedUser() -> Bool {
        UserDefaults.standard.bool(forKey: Key.isVerifiedUser.rawValue)
    }

    func setIsVerifiedUser(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: Key.isVerifiedUser.rawValue)
    }

    func getUser() async -> AuthUser? {
        guard let data = UserDefaults.standard.data(forKey: Key.user.rawValue) else {
            return nil
        }
        do {
            return try JSONDecoder().decode(AuthUser.self, from: data)
        } catch {
            print("AppPreference \(#function) decode error: \(error)")
            return nil
        }
    }

    func setUser(_ user: AuthUser?) async {
        do {
            let data = try JSONEncoder().encode(user)
            UserDefaults.standard.set(data, forKey: Key.user.rawValue)
        } catch {
            print("AppPreference \(#function) encode error: \(error)")
        }
    }

    func clearPreferenceSession() async {
        await setUser(nil)
        setIsVerifiedUser(false)
    }
}
