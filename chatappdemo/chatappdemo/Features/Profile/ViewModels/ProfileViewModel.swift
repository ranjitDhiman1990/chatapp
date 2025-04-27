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
    
    var initialUserData: AuthUser?
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
        self.initialUserData = authViewModel.getCurrentUser()
        self.displayName = self.initialUserData?.displayName ?? ""
        populateFromAuth(phNo: self.initialUserData?.phoneNumber, mail: self.initialUserData?.email)
    }
    
    private func populateFromAuth(phNo: String?, mail: String?) {
        if let phNo = phNo {
            mobileNumber = phNo
            authMobileNumber = phNo
        }
        if let mail = mail {
            email = mail
            authEmail = mail
        }
    }
    
    var hasChanges: Bool {
        guard let original = self.initialUserData else { return false }
        return displayName != original.displayName
    }
    
    @MainActor
    func createProfile(imageUrl: String?) async throws {
        if isValidName {
            guard let currentUser = self.initialUserData?.copyWith(email: email, phoneNumber: mobileNumber, displayName: displayName, photoURL: URL(string: imageUrl ?? self.initialUserData?.photoURL?.absoluteString ?? "")) else { return }
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
    
    @MainActor
    func updateProfile(imageUrl: String?) async throws {
        if isValidName {
            guard let currentUser = self.initialUserData?.copyWith(email: email, phoneNumber: mobileNumber, displayName: displayName, photoURL: URL(string: imageUrl ?? self.initialUserData?.photoURL?.absoluteString ?? "")) else { return }
            do {
                try await authViewModel?.updateUserInFireStoreDB(user: currentUser)
            } catch {
                debugPrint("UpdateProfileError: \(error)")
                throw error
            }
        } else {
            throw ValidationError.userNameEmpty
        }
    }
}
