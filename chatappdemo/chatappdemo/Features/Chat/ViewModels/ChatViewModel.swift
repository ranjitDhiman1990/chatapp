//
//  ChatViewModel.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 23/04/25.
//

import SwiftUI
import Foundation
import FirebaseFirestore

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isTyping: Bool = false
    
    let conversation: UserConversation?
    let currentUser: AuthUser
    let otherUser: AuthUser?
    
    enum ViewState {
        case empty
        case loading
        case hasContent
        case error(Error)
    }
    
    @Published var viewState: ViewState = .loading
    
    private let chatListService: ChatServiceProtocol
    private let userService: UserServiceProtocol
    
    private var listener: ListenerRegistration?
    
    init(
        chatListService: ChatServiceProtocol = ChatService(),
        userService: UserServiceProtocol = UserService(),
        currentUser: AuthUser,
        otherUser: AuthUser?,
        conversation: UserConversation? = nil
    ) {
        self.chatListService = chatListService
        self.userService = userService
        self.currentUser = currentUser
        self.otherUser = otherUser
        self.conversation = conversation
    }
    
    func loadChats() {}
    
    func sendMessage() {}
    
    func createNewConversation() {}
    
    func setTypingIndicator() {}
    
    func markConversationRead() {}
    
    deinit {
        listener?.remove()
    }
}

extension ChatViewModel {
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
