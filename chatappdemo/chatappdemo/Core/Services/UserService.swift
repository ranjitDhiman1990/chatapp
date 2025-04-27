//
//  UserService.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 23/04/25.
//

import FirebaseFirestore

protocol UserServiceProtocol {
    func updateUserStatus(userId: String, status: UserStatus) async throws
    func listenForUserStatus(userId: String) async throws -> AsyncThrowingStream<(userId: String, status: UserStatus), Error>
}

class UserService: FirestoreService<AuthUser>, UserServiceProtocol {
    static let shared = UserService()
    private var statusListeners: [String: ListenerRegistration] = [:]
    
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
    
    func fetchAllUsers() async throws -> [AuthUser] {
        let snapshot = try await db.collection(collectionName).getDocuments()
        return try snapshot.documents.compactMap { doc in
            try doc.data(as: AuthUser.self)
        }
    }
    
    func updateUserStatus(userId: String, status: UserStatus) async throws {
        let userRef = db.collection(collectionName).document(userId)
        if status == .online {
            try await userRef.updateData([
                "status": status.rawValue,
                "lastActive": FieldValue.serverTimestamp()
            ])
        } else {
            try await userRef.updateData([
                "status": status.rawValue
            ])
        }
    }
    
    func listenForUserStatus(userId: String) async throws -> AsyncThrowingStream<(userId: String, status: UserStatus), any Error> {
        statusListeners[userId]?.remove()
        
        return AsyncThrowingStream { continuation in
            let listener = db.collection(collectionName).document(userId)
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        continuation.finish(throwing: error)
                        return
                    }
                    guard let data = snapshot?.data(),
                          let statusString = data["status"] as? String,
                          let status = UserStatus(rawValue: statusString) else {
                        continuation.finish()
                        return
                    }
                    continuation.yield((userId: userId, status: status))
                }
            
            // Store listener for cleanup
            self.statusListeners[userId] = listener
            continuation.onTermination = { @Sendable _ in
                listener.remove()
                self.statusListeners[userId] = nil
            }
        }
    }
}
