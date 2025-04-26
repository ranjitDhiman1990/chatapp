//
//  ImageUploadError.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 26/04/25.
//

enum ImageUploadError: Error {
    case invalidImageData
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .invalidImageData:
            return "Invalid image data"
        case .unknown:
            return "Unknown error"
        }
    }
}
