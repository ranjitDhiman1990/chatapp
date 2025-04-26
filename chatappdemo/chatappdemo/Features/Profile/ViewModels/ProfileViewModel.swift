//
//  ProfileViewModel.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 23/04/25.
//

import SwiftUI
import PhotosUI

class ProfileViewModel: ObservableObject {
    @Published var displayName: String = "" {
        didSet {
            validateDisplayName()
        }
    }
    @Published var isValidName: Bool = false
    @Published var errorName: String?
    
    @Published var mobileNumber: String = ""
    @Published var email: String = ""
    
    @Published var profileImage: UIImage?
    @Published var errorImage: String?
    
    var authMobileNumber: String? = nil
    var authEmail: String? = nil
    
    private func validateDisplayName() {
        if displayName.isEmpty {
            isValidName = false
            errorName = nil
        } else if displayName.count < 3 {
            isValidName = false
            errorName = "Display name must be at least 3 characters"
        } else if displayName.count > 40 {
            isValidName = false
            errorName = "Display name must be less than 40 characters"
        } else {
            isValidName = true
            errorName = nil
        }
    }
    
    func setProfileImage(_ image: UIImage?) {
        profileImage = image
        errorImage = nil
    }
    
    func populateFromAuth() {
        if let authMobileNumber = authMobileNumber {
            mobileNumber = authMobileNumber
        }
        if let authEmail = authEmail {
            email = authEmail
        }
    }
    
    func submitProfile() {
        // Handle profile submission here
        debugPrint("Submitting profile with:")
        debugPrint("Display Name: \(displayName)")
        debugPrint("Mobile: \(mobileNumber)")
        debugPrint("Email: \(email)")
        if let profileImage = profileImage {
            debugPrint("Profile image available (size: \(profileImage.size))")
            // You would typically upload this image to your server
        }
    }
}
