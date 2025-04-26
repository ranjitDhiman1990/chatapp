//
//  ValidationError.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 26/04/25.
//

enum ValidationError: Error {
    case userNameEmpty
    case userNameTooShort
    case userNameTooLong
    case invalidImageData
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .userNameEmpty:
            return "User name is Empty"
        case .userNameTooShort:
            return "User name must be at least 3 characters"
        case .userNameTooLong:
            return "Name must be less than 40 characters"
        case .invalidImageData:
            return "Invalid Image Data"
        case .unknown:
            return "Unknown Error"
        }
    }
}
