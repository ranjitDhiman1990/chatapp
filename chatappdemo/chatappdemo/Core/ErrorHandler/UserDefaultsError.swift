//
//  UserDefaultsError.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 26/04/25.
//

enum UserDefaultsError: Error {
    case encodingError(Error)
    case decodingError(Error)
    
    var localizedDescription: String {
        switch self {
        case .encodingError(let error):
            return "Failed to encode user data: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to decode user data: \(error.localizedDescription)"
        }
    }
}
