//
//  AppSecrets.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 26/04/25.
//

import Foundation

enum AppSecrets {
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist file not found")
        }
        return dict
    }()
    
    static let cloudinaryCloudName: String = {
        guard let value = infoDictionary["CLOUDINARY_CLOUD_NAME"] as? String else {
            fatalError("Cloudinary Cloud Name not set in plist")
        }
        return value
    }()
    
    static let cloudinaryAPIKey: String = {
        guard let value = infoDictionary["CLOUDINARY_API_KEY"] as? String else {
            fatalError("Cloudinary Cloud API Key not set in plist")
        }
        return value
    }()
    
    static let cloudinaryAPISecret: String = {
        guard let value = infoDictionary["CLOUDINARY_API_SECRET"] as? String else {
            fatalError("Cloudinary Cloud API Secret not set in plist")
        }
        return value
    }()
    
    static let cloudinaryUploadPreset: String = {
        guard let value = infoDictionary["CLOUDINARY_UPLOAD_PRESET"] as? String else {
            fatalError("Cloudinary Upload preset not set in plist")
        }
        return value
    }()
}
