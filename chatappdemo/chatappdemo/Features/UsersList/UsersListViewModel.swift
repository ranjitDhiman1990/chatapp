//
//  UsersListViewModel.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 26/04/25.
//

import SwiftUI

class UsersListViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var allUsers: [AuthUser] = []
    @Published var isLoading: Bool = false
    
    
    var filteredUsers: [AuthUser] {
        if  searchText.isEmpty {
            return allUsers
        } else {
            return allUsers.filter {
                $0.displayName?.lowercased().contains(searchText.lowercased()) ?? false || $0.email?.lowercased().contains(searchText.lowercased()) ?? false || $0.phoneNumber?.lowercased().contains(searchText.lowercased()) ?? false
            }
        }
    }
    
    @MainActor
    func loadUsers() async throws {
        isLoading = true
        do {
            allUsers = try await UserService.shared.fetchAllUsers()
        } catch {
            throw error
        }
    }
}
