//
//  UserService.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 23/04/25.
//

class UserService: FirestoreService<AuthUser> {
    static let shared = UserService()
    
    init () {
        super.init(collectionName: "Users")
    }
    
    func getUserByMobile(mobile: String) async throws -> AuthUser? {
        let snapshot = try await db.collection(collectionName).whereField("mobile", isEqualTo: mobile).limit(to: limit ?? 1).getDocuments()
        return snapshot.documents.first.flatMap {
            try? $0.data(as: AuthUser.self)
        }
    }
    
    func getUserByEmail(email: String) async throws -> AuthUser? {
        let snapshot = try await db.collection(collectionName).whereField("email", isEqualTo: email).limit(to: limit ?? 1).getDocuments()
        return snapshot.documents.first.flatMap {
            try? $0.data(as: AuthUser.self)
        }
    }
}
