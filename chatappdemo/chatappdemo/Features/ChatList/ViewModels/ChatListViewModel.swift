//
//  ChatViewModel.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 23/04/25.
//

import SwiftUI
import Foundation
import FirebaseFirestore

class ChatListViewModel: ObservableObject {
    @Published var conversations: [UserConversation] = []
    @Published var filteredConversations: [UserConversation] = []
    @Published var searchText = ""
    
    enum ViewState {
        case empty
        case loading
        case hasContent
        case error(Error)
    }
    
    @Published var viewState: ViewState = .loading
    
    private let chatListService: ChatServiceProtocol
    private let userService: UserServiceProtocol
    let currentUser: AuthUser
    private var listener: ListenerRegistration?
        
    init(
        chatListService: ChatServiceProtocol = ChatService(),
        userService: UserServiceProtocol = UserService(),
        currentUser: AuthUser
    ) {
        self.chatListService = chatListService
        self.userService = userService
        self.currentUser = currentUser
        
        $searchText
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .map { text in
                text.isEmpty
                ? self.conversations
                : self.conversations.filter {
                    $0.otherUserName?.localizedCaseInsensitiveContains(text) ?? false
                }
            }
            .assign(to: &$filteredConversations)
    }
    
    @MainActor
    func loadConversations() async throws {
        viewState = .loading
        
        do {
            let stream = try await chatListService.fetchConversations(for: currentUser.id)
            
            Task {
                do {
                    for try await conversations in stream {
                        let sortedConversations = conversations.sorted {
                            ($0.updatedAt ?? Date.distantPast) > ($1.updatedAt ?? Date.distantPast)
                        }
                        await MainActor.run {
                            self.handleConversationsUpdate(sortedConversations)
                        }
                    }
                } catch {
                    await MainActor.run {
                        self.handleError(error)
                    }
                }
            }
        } catch {
            handleError(error)
        }
    }
    
    private func handleConversationsUpdate(_ conversations: [UserConversation]) {
        self.conversations = conversations
        self.filteredConversations = searchText.isEmpty ? conversations : filteredConversations
        
        // Update view state
        if conversations.isEmpty {
            viewState = .empty
        } else {
            viewState = .hasContent
        }
    }
    
    private func handleError(_ error: Error) {
        viewState = .error(error)
    }
    
    @MainActor
    func deleteConversation(at index: Int) async throws {
        guard let conversationId = filteredConversations[index].conversationId else { return }
        
        Task {
            do {
                try await chatListService.deleteConversation(
                    conversationId: conversationId,
                    for: currentUser.id
                )
                
                if let mainIndex = conversations.firstIndex(where: { $0.id == conversationId }) {
                    conversations.remove(at: mainIndex)
                }
            } catch {
                throw error
            }
        }
    }
    
    deinit {
        listener?.remove()
    }
}

extension ChatListViewModel {
    var shouldShowEmptyState: Bool {
        if case .empty = viewState { return true }
        return false
    }
    
    var shouldShowLoading: Bool {
        if case .loading = viewState { return true }
        return false
    }
    
    var shouldShowError: Bool {
        if case .error = viewState { return true }
        return false
    }
}
