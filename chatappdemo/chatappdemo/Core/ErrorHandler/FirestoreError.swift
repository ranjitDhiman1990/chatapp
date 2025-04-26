//
//  FirestoreError.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 26/04/25.
//

enum FirestoreError: Error {
    case invalidItem
    case notFound
    case snapshotError
    case creationError(Error)
    case decodingError(Error)
    case updateError(Error)
    case deletionError(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidItem: return "Invalid item format"
        case .notFound: return "Document not found"
        case .snapshotError: return "Snapshot error"
        case .creationError(let error): return "Creation failed: \(error.localizedDescription)"
        case .decodingError(let error): return "Decoding failed: \(error.localizedDescription)"
        case .updateError(let error): return "Update failed: \(error.localizedDescription)"
        case .deletionError(let error): return "Deletion failed: \(error.localizedDescription)"
        }
    }
}
