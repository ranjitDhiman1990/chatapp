//
//  EditProfileView.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 23/04/25.
//

import SwiftUI
import CachedAsyncImage

struct EditProfileView: View {
    @EnvironmentObject var router: Router
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @StateObject private var viewModel = ProfileViewModel()
    @StateObject private var imageUploadViewModel = ImageUploadViewModel()
    
    @State private var isLoading: Bool = false
    @State private var showImageSourceSheet = false
    @State private var showImagePicker = false
    @State private var showPhotoPicker = false
    
    var body: some View {
        Form {
            // Profile Image section
            profileImageView
            
            // Display Name section
            displayNameView
            
            // Mobile & Email section(Optional)
            mobileEmailView
            
            // Submit Button
            submitButtonView
        }
        .navigationTitle("Edit Profile")
        .onAppear {
            viewModel.setup(authViewModel: authViewModel)
            imageUploadViewModel.imageUrl = viewModel.initialUserData?.photoURL?.absoluteString
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePickerView(image: $viewModel.profileImage, onImageSelected: { image in
                isLoading = true
                Task {
                    defer {
                        isLoading = false
                    }
                    
                    do {
                        if let image {
                            try await imageUploadViewModel.uploadImage(image)
                        }
                    } catch {
                        debugPrint("Image upload error = \(error.localizedDescription)")
                    }
                }
            })
        }
        .sheet(isPresented: $showPhotoPicker) {
            PhotoPickerView(image: $viewModel.profileImage, onImageSelected: { image in
                isLoading = true
                Task {
                    defer {
                        isLoading = false
                    }
                    
                    do {
                        if let image {
                            try await imageUploadViewModel.uploadImage(image)
                        }
                    } catch {
                        debugPrint("Image upload error = \(error.localizedDescription)")
                    }
                }
            })
        }
        .actionSheet(isPresented: $showImageSourceSheet) {
            ActionSheet(
                title: Text("Select Profile Picture"),
                buttons: [
                    .default(Text("Take Photo")) {
                        showImagePicker = true
                    },
                    .default(Text("Choose from Library")) {
                        showPhotoPicker = true
                    },
                    .cancel()
                ]
            )
        }
        .overlay(LoaderView(isLoading: isLoading))
    }
    
    private var profileImageView: some View {
        Section {
            VStack(alignment: .center, spacing: 8) {
                if let imageUrl = imageUploadViewModel.imageUrl {
                    CachedAsyncImage(url: URL(string: imageUrl)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                        case .empty:
                            ProgressView()
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                } else if let image = viewModel.profileImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                }
                
                if imageUploadViewModel.uploadProgress > 0, imageUploadViewModel.uploadProgress < 1 {
                    ProgressView(value: imageUploadViewModel.uploadProgress, total: 1.0)
                        .padding()
                } else {
                    HStack(spacing: 20) {
                        Button {
                            showImagePicker = true
                        } label: {
                            Text("Choose Photo")
                        }
                    }
                }
                
                if let error = viewModel.errorImage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .listRowBackground(Color.clear)
    }
    
    private var displayNameView: some View {
        Section("Required Information") {
            TextField("Display Name", text: $viewModel.displayName)
                .autocapitalization(.words)
            
            if let error = viewModel.errorName {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
    
    private var mobileEmailView: some View {
        Section("Optional Information") {
            if let authMobileNumber = viewModel.authMobileNumber, !authMobileNumber.isEmpty {
                Text("Mobile: \(authMobileNumber)")
                    .foregroundColor(.gray)
            } else {
                TextField("Mobile Number", text: $viewModel.mobileNumber)
                    .keyboardType(.phonePad)
            }
            
            if let authEmail = viewModel.authEmail, !authEmail.isEmpty {
                Text("Email: \(authEmail)")
                    .foregroundColor(.gray)
            } else {
                TextField("Email", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
        }
    }
    
    private var submitButtonView: some View {
        Section {
            PrimaryButton(text: "Update Profile") {
                isLoading = true
                Task {
                    defer {
                        isLoading = false
                    }
                    
                    do {
                        try await viewModel.updateProfile(imageUrl: imageUploadViewModel.imageUrl)
                    } catch {
                        debugPrint("Update Profile error = \(error.localizedDescription)")
                    }
                }
            }
            .disabled(!viewModel.isValidName)
        }
    }
}
