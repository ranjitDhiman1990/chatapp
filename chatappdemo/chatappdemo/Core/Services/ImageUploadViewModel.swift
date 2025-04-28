//
//  ImageUploadViewModel.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 26/04/25.
//

import UIKit

class ImageUploadViewModel: ObservableObject {
    @Published var uploadProgress: Double = 0
    @Published var imageUrl: String?
    @Published var errorMessage: String?
    
    private var uploadService: ImageUploadServiceProtocol
    
    init(uploadService: ImageUploadServiceProtocol = ImageUploadService()) {
        self.uploadService = uploadService
    }
    
    func updateImageUrl(imgUrl: String) {
        self.imageUrl = imgUrl
    }
    
    func uploadImage(_ image: UIImage) async throws {
        do {
            let url = try await uploadService.uploadImage(image: image) { progress in
                DispatchQueue.main.async {
                    self.uploadProgress = progress
                }
            }
            DispatchQueue.main.async {
                self.imageUrl = url
                self.uploadProgress = 1.0
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.uploadProgress = 0
            }
        }
    }
}
