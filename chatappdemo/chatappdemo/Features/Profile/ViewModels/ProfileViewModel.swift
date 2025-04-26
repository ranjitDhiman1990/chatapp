//
//  ProfileViewModel.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 23/04/25.
//

import SwiftUI
import PhotosUI

class ProfileViewModel: ObservableObject {
    var authViewModel: AuthViewModel?
    
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
            errorName = ValidationError.userNameTooShort.localizedDescription
        } else if displayName.count > 40 {
            isValidName = false
            errorName = ValidationError.userNameTooLong.localizedDescription
        } else {
            isValidName = true
            errorName = nil
        }
    }
    
    func setProfileImage(_ image: UIImage?) {
        profileImage = image
        errorImage = nil
    }
    
    @MainActor
    func setup(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
        let currentUser = authViewModel.getCurrentUser()
        populateFromAuth(phNo: currentUser?.phoneNumber, mail: currentUser?.email)
    }
    
    func populateFromAuth(phNo: String?, mail: String?) {
        if let phNo = phNo {
            mobileNumber = phNo
            authMobileNumber = phNo
        }
        if let mail = mail {
            email = mail
            authEmail = mail
        }
    }
    
    @MainActor
    func submitProfile(imageUrl: String?) async throws {
        if isValidName {
            let user = authViewModel?.getCurrentUser()
            guard let currentUser = user?.copyWith(email: email, phoneNumber: mobileNumber, displayName: displayName, photoURL: URL(string: imageUrl ?? "")) else { return }
            do {
                try await authViewModel?.createUserInFireStoreDB(user: currentUser)
            } catch {
                debugPrint("UpdateProfileError: \(error)")
                throw error
            }
        } else {
            throw ValidationError.userNameEmpty
        }
    }
}
