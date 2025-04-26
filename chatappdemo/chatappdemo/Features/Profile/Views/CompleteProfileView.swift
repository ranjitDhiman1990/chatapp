//
//  CompleteProfileView.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 23/04/25.
//

import SwiftUI

struct CompleteProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
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
        .navigationTitle("Complete Profile")
        .onAppear {
            viewModel.populateFromAuth()
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePickerView(image: $viewModel.profileImage)
        }
        .sheet(isPresented: $showPhotoPicker) {
            PhotoPickerView(image: $viewModel.profileImage)
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
    }
    
    private var profileImageView: some View {
        Section {
            VStack(alignment: .center, spacing: 8) {
                if let image = viewModel.profileImage {
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
                
                HStack(spacing: 20) {
                    Button {
                        showImagePicker = true
                    } label: {
                        Text("Choose Photo")
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
            Button(action: viewModel.submitProfile) {
                HStack {
                    Spacer()
                    Text("Submit")
                        .fontWeight(.semibold)
                    Spacer()
                }
            }
            .disabled(!viewModel.isValidName)
        }
    }
}
