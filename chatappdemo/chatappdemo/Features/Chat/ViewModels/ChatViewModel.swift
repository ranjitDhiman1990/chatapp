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
    @Published var error: Error? = nil
    
    private var typingTimer: Timer?
    
    var conversation: UserConversation?
    let currentUser: AuthUser
    let otherUser: AuthUser?
    
    private var messageStream: AsyncThrowingStream<[Message], Error>?
    private var listenerTask: Task<Void, Never>?
    
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
        if conversation != nil {
            self.conversation = conversation
        } else {
            Task {
                self.conversation = try await self.chatListService.findExistingConversation(between: self.currentUser.id, and: self.otherUser?.id ?? "")
                if self.conversation != nil {
                    await loadChats(lastMessageId: nil)
                }
            }
        }
    }
    
    @MainActor
    func loadChats(lastMessageId: String?) {
        listenerTask = Task {
            do {
                messageStream = try await self.chatListService.fetchMessages(
                    for: self.conversation?.conversationId ?? "",
                    limit: 25,
                    lastMessageId: lastMessageId
                )
                
                guard let messageStream = messageStream else { return }
                
                for try await newMessages in messageStream {
                    let existingIds = Set(messages.map { $0.id })
                    let filteredMessages = newMessages.filter { !existingIds.contains($0.id) }
                    messages.insert(contentsOf: filteredMessages, at: 0)
                }
            } catch {
                debugPrint("Error loading messages: \(error)")
                self.error = error
            }
        }
    }
    
    @MainActor
    func sendMessage(text: String) async throws {
        do {
            if let conversationId = self.conversation?.conversationId, !conversationId.isEmpty {
                let message = try await self.chatListService.sendMessage(
                    conversationId: conversationId,
                    currentUserId: self.currentUser.id,
                    otherUserId: self.otherUser?.id ?? "",
                    text: text
                )
                
                await MainActor.run {
                    messages.append(message)
                }
                
                self.chatListService.trackMessageDeliveryInRealTime(
                    messageId: message.id ?? "",
                    conversationId: self.conversation?.conversationId ?? "",
                    recipientId: self.otherUser?.id ?? ""
                )
            } else if let conversation = try await self.chatListService.findExistingConversation(between: self.currentUser.id, and: self.otherUser?.id ?? ""), let conversationId = self.conversation?.conversationId, !conversationId.isEmpty {
                self.conversation = conversation
                let message = try await self.chatListService.sendMessage(
                    conversationId: conversationId,
                    currentUserId: self.currentUser.id,
                    otherUserId: self.otherUser?.id ?? "",
                    text: text
                )
                
                await MainActor.run {
                    messages.append(message)
                }
                
                self.chatListService.trackMessageDeliveryInRealTime(
                    messageId: message.id ?? "",
                    conversationId: self.conversation?.conversationId ?? "",
                    recipientId: self.otherUser?.id ?? ""
                )
            } else {
                await self.createNewConversation(initialMessage: text)
            }
        } catch {
            debugPrint("sendMessage error: \(error)")
            self.error = error
        }
    }
    
    @MainActor
    func createNewConversation(initialMessage: String) async {
        do {
            let result = try await self.chatListService.createNewConversation(between: self.currentUser, and: self.otherUser!, initialMessage: initialMessage)
            if self.conversation == nil {
                self.conversation = result.1
            }
            
            let message = result.2
            await MainActor.run {
                messages.append(message)
            }
        } catch {
            debugPrint("sendMessage error: \(error)")
            self.error = error
        }
    }
    
    @MainActor
    func setTypingIndicator(
        isTyping: Bool,
        userId: String,
        conversationId: String
    ) {
        typingTimer?.invalidate()
        
        typingTimer = Timer.scheduledTimer(
            withTimeInterval: 0.5,
            repeats: false
        ) { [weak self] _ in
            Task {
                try await self?.chatListService.setTypingIndicator(
                    for: userId,
                    conversationId: conversationId,
                    isTyping: isTyping
                )
            }
        }
    }
    
    @MainActor
    func markConversationRead() async {
        do {
            try await self.chatListService.markConversationRead(
                conversationId: conversation?.conversationId ?? "",
                for: currentUser.id
            )
            
            // Update local state
            await MainActor.run {
                conversation = conversation?.copyWith(unreadCount: 0)
                messages = messages.map { message in
                    var newMessage = message
                    if newMessage.senderId != conversation?.userId {
                        newMessage = newMessage.copyWith(status: .read)
                    }
                    return newMessage
                }
            }
        } catch {
            await MainActor.run {
                self.error = error
            }
        }
    }
    
    func markMessagesAsRead(_ messageIds: [String]) async {
        guard !messageIds.isEmpty else { return }
        
        do {
            try await self.chatListService.markMessagesAsRead(
                messageIds: messageIds,
                conversationId: conversation?.conversationId ?? "",
                userId: conversation?.userId ?? ""
            )
            
            // Update local state
            await MainActor.run {
                conversation = conversation?.copyWith(unreadCount: max(0, (conversation?.unreadCount ?? 0) - messageIds.count))
                messages = messages.map { message in
                    if messageIds.contains(message.id ?? "") {
                        var newMessage = message
                        newMessage = newMessage.copyWith(status: .read)
                        return newMessage
                    }
                    return message
                }
            }
        } catch {
            await MainActor.run {
                self.error = error
            }
        }
    }
    
    func listenForTypingIndicators(conversationId: String, currentUserId: String) {
        let ref = Firestore.firestore().collection("userConversations")
            .document("\(currentUserId)_\(conversationId)")
        
        ref.addSnapshotListener { [weak self] snapshot, _ in
            guard let data = snapshot?.data() else { return }
            
            DispatchQueue.main.async {
                let isTyping = data["isTyping"] as? Bool ?? false
                let userId = data["typingUserId"] as? String
                self?.isTyping = isTyping == true && userId == self?.otherUser?.id
            }
        }
    }
    
    deinit {
        error = nil
        messages.removeAll()
        self.isTyping = false
        messageStream = nil
        listener?.remove()
        listener = nil
        typingTimer?.invalidate()
        typingTimer = nil
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
