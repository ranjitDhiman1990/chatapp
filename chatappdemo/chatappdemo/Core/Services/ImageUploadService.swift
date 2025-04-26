//
//  Untitled.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 26/04/25.
//

import UIKit
import Cloudinary

protocol ImageUploadServiceProtocol {
    func uploadImage(image: UIImage) async throws -> String
    func uploadImage(
        image: UIImage,
        progressHandler: ((Double) -> Void)?
    ) async throws -> String
}

public class ImageUploadService: ImageUploadServiceProtocol {
    private let cloudinary: CLDCloudinary
    
    init() {
        cloudinary = CLDCloudinary(
            configuration: CLDConfiguration(
                cloudName: AppSecrets.cloudinaryCloudName,
                apiKey: AppSecrets.cloudinaryAPIKey,
                apiSecret: AppSecrets.cloudinaryAPISecret
            )
        )
    }
    
    // Upload image without progress handler support
    func uploadImage(image: UIImage) async throws -> String {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw ImageUploadError.invalidImageData
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let params = CLDUploadRequestParams()
                .setFolder("user_uploads")
                .setTransformation(CLDTransformation().setWidth(800))
            cloudinary.createUploader().signedUpload(
                data: data,
                params: params, completionHandler:  { result, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let url = result?.url {
                        continuation.resume(returning: url)
                    } else {
                        continuation.resume(throwing: ImageUploadError.unknown)
                    }
                })
        }
    }
    
    // Upload image with progress handler support
    func uploadImage(
        image: UIImage,
        progressHandler: ((Double) -> Void)?
    ) async throws -> String {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw ImageUploadError.invalidImageData
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let params = CLDUploadRequestParams()
                .setFolder("user_uploads")
                .setTransformation(CLDTransformation().setWidth(800))
            cloudinary.createUploader().signedUpload(
                data: data,
                params: params, completionHandler:  { result, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let url = result?.url {
                        continuation.resume(returning: url)
                    } else {
                        continuation.resume(throwing: ImageUploadError.unknown)
                    }
                })
        }
    }
}

