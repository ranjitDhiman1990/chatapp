//
//  UsersListView.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 26/04/25.
//

import SwiftUI

struct UsersListView: View {
    @StateObject private var viewModel = UsersListViewModel()
    let currentUser: AuthUser
    var onUserSelected: (AuthUser) -> Void
    @State private var isLoading: Bool = false
    
    var body: some View {
        VStack {
            UserSearchBar(text: $viewModel.searchText)
                .padding()
            
            List(viewModel.filteredUsers) { user in
                if user.id != currentUser.id {
                    Button {
                        startNewConversation(with: user)
                    } label: {
                        UserRow(user: user)
                    }
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle("New Message")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isLoading = true
            Task {
                defer {
                    isLoading = false
                }
                do {
                    try await viewModel.loadUsers()
                } catch {
                    debugPrint("Load Users error = \(error.localizedDescription)")
                }
            }
        }
        .overlay(LoaderView(isLoading: isLoading))
    }
    
    private func startNewConversation(with user: AuthUser) {
        onUserSelected(user)
    }
}

struct UserSearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search", text: $text)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct UserRow: View {
    let user: AuthUser
    
    var body: some View {
        HStack(spacing: 12) {
            ProfileImageView(imageUrl: user.photoURL?.absoluteString, size: 40)
            
            VStack(alignment: .leading) {
                Text(user.displayName ?? "")
                    .font(.headline)
            }
        }
        .padding(.vertical, 8)
    }
}


struct ProfileImageView: View {
    let imageUrl: String?
    let size: CGFloat
    
    var body: some View {
        Group {
            if let imageUrl = imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .foregroundColor(.gray.opacity(0.3))
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}
