//
//  ChatService.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 23/04/25.
//

import FirebaseFirestore

protocol ChatServiceProtocol {
    func createNewConversation(
        between currentUsewrId: String,
        and otherUserId: String,
        initialMessage: String
    ) async throws -> String
    
    func fetchConversations(for userId: String) async throws -> AsyncThrowingStream<[Conversation], Error>
    
    func markConversationRead(
        conversationId: String,
        for userId: String
    ) async throws
    
    func deleteConversation(
        conversationId: String,
        for userId: String
    ) async throws
    
    func sendMessage(
        to conversationId: String,
        from userId: String,
        with text: String
    ) async throws
    
    func fetchMessages(
        for conversationId: String,
        limit: Int,
        lastMessageId: String?
    ) async throws -> AsyncThrowingStream<[Message], Error>
    
    func setTypingIndicator(
        for userId: String,
        conversationId: String,
        isTyping: Bool
    ) async throws
    
    func updateUserStatus(
        userId: String,
        status: AuthUser.UserStatus
    ) async throws
    
    func findExistingConversation(
        between currentUserId: String,
        and otherUserId: String
    ) async throws -> String?
}


class ChatService: ChatServiceProtocol {
    private let db = Firestore.firestore()
    
    func createNewConversation(between currentUserId: String, and otherUserId: String, initialMessage: String) async throws -> String {
        let conversationId = UUID().uuidString
        let timeStamp = Date()
        
        let lastMessage = LastMessage(text: initialMessage, senderId: currentUserId, timestamp: timeStamp)
        
        let conversation = Conversation(id: conversationId, participants: [currentUserId: true, otherUserId: true], lastMessage: lastMessage, createdAt: timeStamp, updatedAt: timeStamp)
        
        let currentUserConversation = UserConversation(id: nil, userId: currentUserId, conversationId: conversationId, otherUserId: otherUserId, lastMessage: lastMessage, unreadCount: 0, isTyping: false, updatedAt: timeStamp)
        
        let otherUserConversation = UserConversation(id: nil, userId: otherUserId, conversationId: conversationId, otherUserId: currentUserId, lastMessage: lastMessage, unreadCount: 1, isTyping: false, updatedAt: timeStamp)
        
        let message = Message(id: nil, senderId: currentUserId, content: initialMessage, type: Message.MessageType.text, timestamp: timeStamp, status: Message.MessageStatus.sent)
        
        let batch = db.batch()
        
        // Main conversation document
        let conversationRef = db.collection("conversations").document(conversationId)
        batch.setData(conversation.toDictionary() ?? [:], forDocument: conversationRef)
        
        // User-specific entries
        let userARef = db.collection("userConversations").document("\(currentUserId)_\(conversationId)")
        batch.setData(currentUserConversation.toDictionary() ?? [:], forDocument: userARef)
        
        let userBRef = db.collection("userConversations").document("\(otherUserId)_\(conversationId)")
        batch.setData(otherUserConversation.toDictionary() ?? [:], forDocument: userBRef)
        
        // First message
        let messageRef = conversationRef.collection("messages").document()
        batch.setData(message.toDictionary() ?? [:], forDocument: messageRef)
        
        try await batch.commit()
    }
    
    func fetchConversations(for userId: String) async throws -> AsyncThrowingStream<[Conversation], any Error> {
        // TODO :-
    }
    
    func markConversationRead(conversationId: String, for userId: String) async throws {
        // TODO :-
    }
    
    func deleteConversation(conversationId: String, for userId: String) async throws {
        // TODO :-
    }
    
    func sendMessage(to conversationId: String, from userId: String, with text: String) async throws {
        //let existingConversationId = try await findExistingConversation(between: <#T##String#>, and: <#T##String#>)
    }
    
    func fetchMessages(for conversationId: String, limit: Int, lastMessageId: String?) async throws -> AsyncThrowingStream<[Message], any Error> {
        // TODO :-
    }
    
    func setTypingIndicator(for userId: String, conversationId: String, isTyping: Bool) async throws {
        // TODO :-
    }
    
    func updateUserStatus(userId: String, status: AuthUser.UserStatus) async throws {
        // TODO :-
    }
    
    func findExistingConversation(between currentUserId: String, and otherUserId: String) async throws -> String? {
        let query = db.collection("userConversations")
            .whereField("userId", isEqualTo: currentUserId)
            .whereField("otherUserId", isEqualTo: otherUserId)
            .limit(to: 1)
        
        let snapshot = try await query.getDocuments()
        return snapshot.documents.first?.data()["conversationId"] as? String
    }
    
}
