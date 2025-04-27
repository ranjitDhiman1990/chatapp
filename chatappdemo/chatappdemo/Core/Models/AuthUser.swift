//
//  AuthUser.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 23/04/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

struct AuthUser: Identifiable, Codable, Hashable {
    let id: String
    let email: String?
    let phoneNumber: String?
    let displayName: String?
    let photoURL: URL?
    let status: UserStatus?
    let lastActive: Date?
    let createdAt: Date?
    
    init(
        id: String,
        email: String? = nil,
        phoneNumber: String? = nil,
        displayName: String? = nil,
        photoURL: URL? = nil,
        status: UserStatus? = nil,
        lastActive: Date? = nil,
        createdAt: Date? = nil
    ) {
        self.id = id
        self.email = email
        self.phoneNumber = phoneNumber
        self.displayName = displayName
        self.photoURL = photoURL
        self.status = status
        self.lastActive = lastActive
        self.createdAt = createdAt
    }
    
    init(user: User) {
        self.id = user.uid
        self.email = user.email
        self.phoneNumber = user.phoneNumber
        self.displayName = user.displayName
        self.photoURL = user.photoURL
        self.status = nil
        self.lastActive = nil
        self.createdAt = user.metadata.creationDate
    }
    
    func copyWith(
        id: String? = nil,
        email: String? = nil,
        phoneNumber: String? = nil,
        displayName: String? = nil,
        photoURL: URL? = nil,
        status: UserStatus? = nil,
        lastActive: Date? = nil,
        createdAt: Date? = nil
    ) -> AuthUser {
        return AuthUser(
            id: id ?? self.id,
            email: email ?? self.email,
            phoneNumber: phoneNumber ?? self.phoneNumber,
            displayName: displayName ?? self.displayName,
            photoURL: photoURL ?? self.photoURL,
            status: status ?? self.status,
            lastActive: lastActive ?? self.lastActive,
            createdAt: createdAt ?? self.createdAt
        )
    }
    
    func toDictionary() -> [String: Any]? {
        return try? Firestore.Encoder().encode(self)
    }
    
    static func fromDictionary(_ dictionary: [String: Any]) -> UserConversation? {
        guard let data = try? JSONSerialization.data(withJSONObject: dictionary) else { return nil }
        return try? JSONDecoder().decode(UserConversation.self, from: data)
    }
    
    func toJSON() -> Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            return try encoder.encode(self)
        } catch {
            debugPrint("Error encoding to JSON: \(error)")
            return nil
        }
    }
    
    func toJSONString() -> String? {
        guard let data = toJSON() else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case phoneNumber
        case displayName
        case photoURL
        case status
        case lastActive
        case createdAt
    }
}

enum UserStatus: String, Codable {
    case online, offline
}
