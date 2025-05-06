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
    @Published var error: Error? = nil
    @Published var isLoadingPrevious = false
    @Published var canLoadMore = true
        
    private var lastDocumentSnapshot: DocumentSnapshot?
    private let pageSize = 25
    
    @Published var newMessage = "" {
        didSet {
            handleTextEditingChange()
        }
    }
    private let typingDebounceInterval: TimeInterval = 2.0
    private var typingTimer: Timer?
    private var appStateObserver: NSObjectProtocol?
    
    @Published var otherUserTyping: Bool = false
    @Published var typingUserName: String = ""
    private var typingListener: ListenerRegistration?
    
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
            if let conversationId = self.conversation?.conversationId, !conversationId.isEmpty {
                self.listenForTypingIndicator(conversationId: conversationId, currentUserId: self.currentUser.id)
            }
        } else {
            Task {
                self.conversation = try await self.chatListService.findExistingConversation(between: self.currentUser.id, and: self.otherUser?.id ?? "")
                if self.conversation != nil {
                    await loadChats(lastMessageId: nil)
                    if let conversationId = self.conversation?.conversationId, !conversationId.isEmpty {
                        self.listenForTypingIndicator(conversationId: conversationId, currentUserId: self.currentUser.id)
                    }
                }
            }
        }
        
        setupAppStateObserver()
    }
    
    @MainActor
    func loadChats(lastMessageId: String?) {
        listenerTask = Task {
            do {
                messageStream = try await self.chatListService.fetchMessages(
                    for: self.conversation?.conversationId ?? "",
                    limit: pageSize,
                    lastMessageId: lastMessageId
                )
                
                guard let messageStream = messageStream else { return }
                
                guard !isLoadingPrevious, canLoadMore else { return }
                
                isLoadingPrevious = true
                
                for try await newMessages in messageStream {
                    let existingIds = Set(messages.map { $0.id })
                    let filteredMessages = newMessages.filter { !existingIds.contains($0.id) }
                    messages.insert(contentsOf: filteredMessages, at: 0)
                    sortMessagesInDecendingOrder()
                    
                    
                    await markConversationRead()
                    let ids = filteredMessages.compactMap { $0.id }
                    await markMessagesAsRead(ids)
                    
                    canLoadMore = newMessages.count == pageSize
                    isLoadingPrevious = false
                }
            } catch {
                debugPrint("Error loading messages: \(error)")
                isLoadingPrevious = false
                self.error = error
            }
        }
    }
    
    private func sortMessagesInDecendingOrder() {
        messages.sort { msg1, msg2 in
            if let msg1Timestamp = msg1.timestamp,
               let msg2Timestamp = msg2.timestamp
            {
                return msg1Timestamp < msg2Timestamp
            }
            return msg1.timestamp == msg2.timestamp
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
                    sortMessagesInDecendingOrder()
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
                    sortMessagesInDecendingOrder()
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
                sortMessagesInDecendingOrder()
                
                if let conversationId = self.conversation?.conversationId, !conversationId.isEmpty {
                    self.listenForTypingIndicator(conversationId: conversationId, currentUserId: self.currentUser.id)
                }
            }
        } catch {
            debugPrint("sendMessage error: \(error)")
            self.error = error
        }
    }
    
    func handleTextEditingChange() {
        // Cancel previous timer
        typingTimer?.invalidate()
        
        // Only send typing true if there's actual text
        if !newMessage.isEmpty, let conversationId = self.conversation?.conversationId {
            Task { [weak self] in
                guard let _self = self else { return }
                await _self.setTypingIndicator(isTyping: true, userId: _self.currentUser.id, conversationId: conversationId)
            }
            
        }
        
        // Set up new timer to send false after pause
        typingTimer = Timer.scheduledTimer(
            withTimeInterval: typingDebounceInterval,
            repeats: false
        ) { [weak self] _ in
            Task { [weak self] in
                if let strongSelf = self,
                   let conversationId = strongSelf.conversation?.conversationId {
                    await strongSelf.setTypingIndicator(
                        isTyping: false,
                        userId: strongSelf.currentUser.id,
                        conversationId: conversationId
                    )
                }
            }
        }
    }
    
    @MainActor
    func setTypingIndicator(
        isTyping: Bool,
        userId: String,
        conversationId: String,
        appState: AppState = .active
    ) {
        Task {
            try await self.chatListService.setTypingIndicator(
                for: userId,
                conversationId: conversationId,
                isTyping: isTyping,
                appState: appState
            )
        }
    }
    
    private func setupAppStateObserver() {
        appStateObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { [weak self] in
                if let strongSelf = self,
                   let conversationId = strongSelf.conversation?.conversationId {
                    await strongSelf.setTypingIndicator(
                        isTyping: false,
                        userId: strongSelf.currentUser.id,
                        conversationId: conversationId
                    )
                }
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
    
    func listenForTypingIndicator(conversationId: String, currentUserId: String) {
        // Remove previous listener if exists
        typingListener?.remove()
        
        let db = Firestore.firestore()
        let docRef = db.collection("userConversations")
            .document("\(currentUserId)_\(conversationId)")
        
        typingListener = docRef.addSnapshotListener { [weak self] snapshot, _ in
            guard let data = snapshot?.data(),
                  let isTyping = data["isTyping"] as? Bool,
                  let typingUserId = data["otherUserId"] as? String,
                  typingUserId != currentUserId else {
                self?.otherUserTyping = false
                return
            }
            
            self?.otherUserTyping = isTyping
            if let name = data["otherUserName"] as? String {
                self?.typingUserName = name
            }
        }
    }
    
    deinit {
        error = nil
        messages.removeAll()
        messageStream = nil
        listenerTask?.cancel()
        listenerTask = nil
        typingListener?.remove()
        typingListener = nil
        typingTimer?.invalidate()
        typingTimer = nil
        if let observer = appStateObserver {
            NotificationCenter.default.removeObserver(observer)
        }
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
