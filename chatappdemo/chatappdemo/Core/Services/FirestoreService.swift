//
//  FirestoreService.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 23/04/25.
//

import FirebaseFirestore

protocol FirestoreServiceProtocol {
    associatedtype T: Codable & Identifiable
    
    var collectionName: String { get }
    
    func create(_ item: T) async throws
    func read(id: String) async throws -> T?
    func readAll(id: String) async throws -> [T?]
    func update(_ item: T) async throws
    func delete(id: String) async throws
    func observeSingleDataChanges(id: String) async -> AsyncThrowingStream<T, Error>
    func observeCollectionDataChanges(id: String) async -> AsyncThrowingStream<[T], Error>
}

class FirestoreService<T: Codable & Identifiable>: FirestoreServiceProtocol {
    
    let db = Firestore.firestore()
    let collectionName: String
    let limit: Int? = 1
    
    init(collectionName: String) {
        self.collectionName = collectionName
    }
    
    func create(_ item: T) async throws {
        guard let id = item.id as? String else {
            throw FirestoreError.invalidItem
        }
        
        do {
            try db.collection(collectionName).document(id).setData(from: item)
        } catch {
            throw FirestoreError.creationError(error)
        }
    }
    
    func read(id: String) async throws -> T? {
        let document = try await db.collection(collectionName).document(id).getDocument()
        
        guard document.exists else {
            throw FirestoreError.notFound
        }
        
        do {
            return try document.data(as: T.self)
        } catch {
            throw FirestoreError.decodingError(error)
        }
    }
    
    func readAll(id: String) async throws -> [T?] {
        var query = db.collection(collectionName)
        
        if let limit = limit, let queryRef = query.limit(to: limit) as? CollectionReference {
            query = queryRef
        }
        
        let snapshot = try await query.getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: T?.self)
        }
    }
    
    func update(_ item: T) async throws {
        guard let id = item.id as? String else {
            throw FirestoreError.invalidItem
        }
        
        do {
            try db.collection(collectionName).document(id).setData(from: item, merge: true)
        } catch {
            throw FirestoreError.updateError(error)
        }
    }
    
    func delete(id: String) async throws {
        do {
            try await db.collection(collectionName).document(id).delete()
        } catch {
            throw FirestoreError.deletionError(error)
        }
    }
    
    func observeSingleDataChanges(id: String) async -> AsyncThrowingStream<T, any Error> {
        AsyncThrowingStream { continuation in
            let listener = db.collection(collectionName).document(id)
                .addSnapshotListener { document, error in
                    if let error = error {
                        continuation.finish(throwing: error)
                        return
                    }
                    
                    guard let document = document, document.exists else {
                        continuation.finish(throwing: FirestoreError.notFound)
                        return
                    }
                    
                    do {
                        let item = try document.data(as: T.self)
                        continuation.yield(item)
                    } catch {
                        continuation.finish(throwing: error)
                    }
                }
            
            continuation.onTermination = { @Sendable _ in
                listener.remove()
            }
        }
    }
    
    func observeCollectionDataChanges(id: String) async -> AsyncThrowingStream<[T], any Error> {
        AsyncThrowingStream { continuation in
            let listener = db.collection(collectionName)
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        continuation.finish(throwing: error)
                        return
                    }
                    
                    guard let snapshot = snapshot else {
                        continuation.finish(throwing: FirestoreError.snapshotError)
                        return
                    }
                    
                    let items = snapshot.documents.compactMap { document in
                        try? document.data(as: T.self)
                    }
                    
                    continuation.yield(items)
                }
            
            continuation.onTermination = { @Sendable _ in
                listener.remove()
            }
        }
    }
}
