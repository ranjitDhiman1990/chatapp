//
//  AuthUser.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 23/04/25.
//

import Foundation
import FirebaseAuth

struct AuthUser: Identifiable, Codable, Hashable {
    let id: String
    let email: String?
    let phoneNumber: String?
    let displayName: String?
    let photoURL: URL?
    
    init(
        id: String,
        email: String? = nil,
        phoneNumber: String? = nil,
        displayName: String? = nil,
        photoURL: URL? = nil
    ) {
        self.id = id
        self.email = email
        self.phoneNumber = phoneNumber
        self.displayName = displayName
        self.photoURL = photoURL
    }
    
    init(user: User) {
        self.id = user.uid
        self.email = user.email
        self.phoneNumber = user.phoneNumber
        self.displayName = user.displayName
        self.photoURL = user.photoURL
    }
    
    func copyWith(
        id: String? = nil,
        email: String? = nil,
        phoneNumber: String? = nil,
        displayName: String? = nil,
        photoURL: URL? = nil
    ) -> AuthUser {
        return AuthUser(
            id: id ?? self.id,
            email: email ?? self.email,
            phoneNumber: phoneNumber ?? self.phoneNumber,
            displayName: displayName ?? self.displayName,
            photoURL: photoURL ?? self.photoURL
        )
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case phoneNumber
        case displayName
        case photoURL
    }
}
