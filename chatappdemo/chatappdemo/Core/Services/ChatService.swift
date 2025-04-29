//
//  ChatService.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 23/04/25.
//

import FirebaseFirestore

protocol ChatServiceProtocol {
    func createNewConversation(
        between currentUser: AuthUser,
        and otherUser: AuthUser,
        initialMessage: String
    ) async throws -> (Conversation, UserConversation, Message)
    
    func updateExistingConversation(
        conversationId: String,
        currentUserId: String,
        otherUserId: String,
        lastMessage: String
    ) async throws
    
    func fetchConversations(for userId: String) async throws -> AsyncThrowingStream<[UserConversation], Error>
    
    func markConversationRead(
        conversationId: String,
        for userId: String
    ) async throws
    
    func markMessagesAsRead(
        messageIds: [String],
        conversationId: String,
        userId: String
    ) async throws
    
    func deleteConversation(
        conversationId: String,
        for userId: String
    ) async throws
    
    func sendMessage(
        conversationId: String,
        currentUserId: String,
        otherUserId: String,
        text: String
    ) async throws -> Message
    
    func fetchMessages(
        for conversationId: String,
        limit: Int,
        lastMessageId: String?
    ) async throws -> AsyncThrowingStream<[Message], Error>
    
    func setTypingIndicator(
        for userId: String,
        conversationId: String,
        isTyping: Bool,
        appState: AppState
    ) async throws
    
    func findExistingConversation(
        between currentUserId: String,
        and otherUserId: String
    ) async throws -> UserConversation?
    
    func trackMessageDeliveryInRealTime(
        messageId: String,
        conversationId: String,
        recipientId: String
    )
    
    func updateMessageStatusToDelivered(
        messageId: String,
        conversationId: String,
        recipientId: String
    ) async throws
}


class ChatService: ChatServiceProtocol {
    private let db = Firestore.firestore()
    let userConversationCollectionName = "userConversations"
    let conversationsCollectionName = "conversations"
    let messagesCollectionName = "messages"
    let usersCollectionName = "Users"
    
    private var deliveryHandlers: [String: ListenerRegistration] = [:]
    
    // For Typing Indicator
    private var typingStateTasks: [String: Task<Void, Never>] = [:]
    private let backgroundTaskIdentifier = "com.app.chatappdemo.typingIndicatorUpdate"
    
    func createNewConversation(between currentUser: AuthUser, and otherUser: AuthUser, initialMessage: String) async throws -> (Conversation, UserConversation, Message) {
        let conversationId = UUID().uuidString
        let timeStamp = Date()
        
        let lastMessage = LastMessage(text: initialMessage, senderId: currentUser.id, timestamp: timeStamp)
        
        let conversation = Conversation(id: conversationId, participants: [currentUser.id: true, otherUser.id: true], lastMessage: lastMessage, createdAt: timeStamp, updatedAt: timeStamp)
        
        let currentUserConversation = UserConversation(id: nil, userId: currentUser.id, userName: currentUser.displayName, userImageUrl: currentUser.photoURL?.absoluteString, conversationId: conversationId, otherUserId: otherUser.id, otherUserName: otherUser.displayName, otherUserImageUrl: otherUser.photoURL?.absoluteString, lastMessage: lastMessage, unreadCount: 0, isTyping: false, typingUserId: nil, updatedAt: timeStamp)
        
        let otherUserConversation = UserConversation(id: nil, userId: otherUser.id, userName: otherUser.displayName, userImageUrl: otherUser.photoURL?.absoluteString, conversationId: conversationId, otherUserId: currentUser.id, otherUserName: currentUser.displayName, otherUserImageUrl: currentUser.photoURL?.absoluteString, lastMessage: lastMessage, unreadCount: 1, isTyping: false, typingUserId: nil, updatedAt: timeStamp)
        
        let message = Message(id: nil, senderId: currentUser.id, content: initialMessage, type: Message.MessageType.text, timestamp: timeStamp, status: Message.MessageStatus.delivered, readAt: nil)
        
        let batch = db.batch()
        
        // Main conversation document
        let conversationRef = db.collection(conversationsCollectionName).document(conversationId)
        batch.setData(conversation.toDictionary() ?? [:], forDocument: conversationRef)
        
        // User-specific entries
        let currentUserRef = db.collection(userConversationCollectionName).document("\(currentUser.id)_\(conversationId)")
        batch.setData(currentUserConversation.toDictionary() ?? [:], forDocument: currentUserRef)
        
        let otherUserRef = db.collection(userConversationCollectionName).document("\(otherUser.id)_\(conversationId)")
        batch.setData(otherUserConversation.toDictionary() ?? [:], forDocument: otherUserRef)
        
        // First message
        let messageRef = conversationRef.collection(messagesCollectionName).document()
        batch.setData(message.toDictionary() ?? [:], forDocument: messageRef)
        
        try await batch.commit()
        
        return (conversation, currentUserConversation, message)
    }
    
    func updateExistingConversation(
        conversationId: String,
        currentUserId: String,
        otherUserId: String,
        lastMessage: String
    ) async throws {
        let batch = db.batch()
        let timestamp = Date()
        
        let lastMessage = LastMessage(text: lastMessage, senderId: currentUserId, timestamp: timestamp)
        
        let conversationRef = db.collection(conversationsCollectionName).document(conversationId)
        batch.updateData([
            "lastMessage": try Firestore.Encoder().encode(lastMessage),
            "updatedAt": timestamp
        ], forDocument: conversationRef)
        
        try updateUserConversation(
            batch: batch,
            userId: currentUserId,
            otherUserId: otherUserId,
            conversationId: conversationId,
            lastMessage: lastMessage,
            incrementUnread: false
        )
        
        try updateUserConversation(
            batch: batch,
            userId: otherUserId,
            otherUserId: currentUserId,
            conversationId: conversationId,
            lastMessage: lastMessage,
            incrementUnread: true
        )
        
        try await batch.commit()
    }
    
    private func updateUserConversation(
        batch: WriteBatch,
        userId: String,
        otherUserId: String,
        conversationId: String,
        lastMessage: LastMessage,
        incrementUnread: Bool
    ) throws {
        let userConversationRef = db.collection(userConversationCollectionName)
            .document("\(userId)_\(conversationId)")
        
        var updateData: [String: Any] = [
            "lastMessage": try Firestore.Encoder().encode(lastMessage),
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        if incrementUnread {
            updateData["unreadCount"] = FieldValue.increment(Int64(1))
        }
        
        batch.setData(updateData, forDocument: userConversationRef, merge: true)
    }
    
    func fetchConversations(for userId: String) async throws -> AsyncThrowingStream<[UserConversation], any Error> {
        let query = db.collection(userConversationCollectionName)
            .whereField("userId", isEqualTo: userId)
            .order(by: "updatedAt", descending: true)
        
        return AsyncThrowingStream { continuation in
            let listener = query.addSnapshotListener { snapshot, error in
                if let error = error {
                    continuation.finish(throwing: error)
                    return
                }
                
                do {
                    let conversations = try snapshot?.documents.compactMap { doc in
                        try doc.data(as: UserConversation.self)
                    } ?? []
                    continuation.yield(conversations)
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            
            continuation.onTermination = { @Sendable _ in
                listener.remove()
            }
        }
    }
    
    func markConversationRead(conversationId: String, for userId: String) async throws {
        let userConversationQuery = db.collection(userConversationCollectionName)
            .document("\(userId)_\(conversationId)")
        
        let messagesQuery = db.collection(conversationsCollectionName)
            .document(conversationId)
            .collection(messagesCollectionName)
            .whereField("status", isEqualTo: "delivered")
            .whereField("senderId", isNotEqualTo: userId)
        
        let batch = db.batch()
        
        batch.updateData([
            "unreadCount": 0,
            "updatedAt": FieldValue.serverTimestamp()
        ], forDocument: userConversationQuery)
        
        let snapshot = try await messagesQuery.getDocuments()
        
        for doc in snapshot.documents {
            batch.updateData([
                "status": "read",
                "readAt": FieldValue.serverTimestamp()
            ], forDocument: doc.reference)
        }
        
        try await batch.commit()
    }
    
    func markMessagesAsRead(messageIds: [String], conversationId: String, userId: String) async throws {
        let batch = db.batch()
        let messagesRef = db.collection(conversationsCollectionName)
            .document(conversationId)
            .collection(messagesCollectionName)
        
        // Update each message
        for messageId in messageIds {
            let messageRef = messagesRef.document(messageId)
            batch.updateData([
                "status": "read",
                "readAt": FieldValue.serverTimestamp()
            ], forDocument: messageRef)
        }
        
        // Update conversation unread count
        let userConversationRef = db.collection(userConversationCollectionName)
            .document("\(userId)_\(conversationId)")
        
        batch.updateData([
            "unreadCount": FieldValue.increment(Int64(-messageIds.count)),
            "updatedAt": FieldValue.serverTimestamp()
        ], forDocument: userConversationRef)
        
        try await batch.commit()
    }
    
    func deleteConversation(conversationId: String, for userId: String) async throws {
        let batch = db.batch()
        
        let messagesRef = db.collection(conversationsCollectionName)
            .document(conversationId)
            .collection(messagesCollectionName)
        
        let messages = try await messagesRef.getDocuments()
        messages.documents.forEach { batch.deleteDocument($0.reference) }
        
        let userConversations = try await db.collection(userConversationCollectionName)
            .whereField("conversationId", isEqualTo: conversationId)
            .getDocuments()
        
        userConversations.documents.forEach { batch.deleteDocument($0.reference) }
        
        let conversationRef = db.collection(conversationsCollectionName).document(conversationId)
        batch.deleteDocument(conversationRef)
        
        try await batch.commit()
    }
    
    func sendMessage(
        conversationId: String,
        currentUserId: String,
        otherUserId: String,
        text: String
    ) async throws -> Message {
        let messageId = UUID().uuidString
        let timeStamp = Date()
        
        let message = Message(id: messageId, senderId: currentUserId, content: text, type: Message.MessageType.text, timestamp: timeStamp, status: Message.MessageStatus.delivered, readAt: nil)
        
        let lastMessage = LastMessage(text: text, senderId: currentUserId, timestamp: timeStamp)
        
        let batch = db.batch()
        let messageRef = db.collection(conversationsCollectionName)
            .document(conversationId)
            .collection(messagesCollectionName)
            .document(messageId)
        batch.setData(message.toDictionary() ?? [:], forDocument: messageRef)
        
        let conversationRef = db.collection(conversationsCollectionName)
            .document(conversationId)
        batch.updateData([
            "lastMessage": try Firestore.Encoder().encode(lastMessage),
            "updatedAt": timeStamp
        ], forDocument: conversationRef)
        
        try updateUserConversation(
            batch: batch,
            userId: currentUserId,
            otherUserId: otherUserId,
            conversationId: conversationId,
            lastMessage: lastMessage,
            incrementUnread: false
        )
        
        try updateUserConversation(
            batch: batch,
            userId: otherUserId,
            otherUserId: currentUserId,
            conversationId: conversationId,
            lastMessage: lastMessage,
            incrementUnread: true
        )
        
        try await batch.commit()
        return message
    }
    
    func fetchMessages(
        for conversationId: String,
        limit: Int = 25,
        lastMessageId: String? = nil
    ) async throws -> AsyncThrowingStream<[Message], any Error> {
        var query = db.collection(conversationsCollectionName)
            .document(conversationId)
            .collection(messagesCollectionName)
            .order(by: "timestamp", descending: false)
            .limit(to: limit)
        
        if let lastMessageId = lastMessageId {
            let lastMessageRef = db.collection(conversationsCollectionName)
                .document(conversationId)
                .collection(messagesCollectionName)
                .document(lastMessageId)
            
            let lastMessage = try await lastMessageRef.getDocument()
            query = query.start(afterDocument: lastMessage)
        }
        
        return AsyncThrowingStream { continuation in
            let listener = query.addSnapshotListener { snapshot, error in
                if let error = error {
                    continuation.finish(throwing: error)
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    continuation.finish()
                    return
                }
                
                do {
                    let messages = try documents.compactMap { document in
                        try document.data(as: Message.self)
                    }
                    continuation.yield(messages)
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            
            continuation.onTermination = { @Sendable _ in
                listener.remove()
            }
        }
    }
    
    func setTypingIndicator(for userId: String, conversationId: String, isTyping: Bool, appState: AppState) async throws {
        typingStateTasks[conversationId]?.cancel()
        
        // Handle different app states
        switch appState {
        case .active, .inactive:
            try await updateTypingStateDirectly(
                userId: userId,
                conversationId: conversationId,
                isTyping: isTyping
            )
            
        case .background:
            try await handleBackgroundStateUpdate(
                userId: userId,
                conversationId: conversationId
            )
            
        case .terminated:
            try await handleBackgroundStateUpdate(
                userId: userId,
                conversationId: conversationId
            )
        }
    }
    
    private func updateTypingStateDirectly(
        userId: String,
        conversationId: String,
        isTyping: Bool
    ) async throws {
        let conversationRef = db.collection(conversationsCollectionName).document(conversationId)
        let conversation = try await conversationRef.getDocument(as: Conversation.self)
        
        let batch = db.batch()
        if let participants = conversation.participants {
            for participantId in participants.keys where participantId != userId {
                let userConversationRef = db.collection(userConversationCollectionName)
                    .document("\(participantId)_\(conversationId)")
                
                batch.updateData([
                    "isTyping": isTyping,
                    "typingUserId": isTyping ? userId : FieldValue.delete(),
                    "updatedAt": FieldValue.serverTimestamp()
                ], forDocument: userConversationRef)
            }
        }
        
        try await batch.commit()
    }
    
    private func handleBackgroundStateUpdate(
        userId: String,
        conversationId: String
    ) async throws {
        // Register background task
        let backgroundTask = await UIApplication.shared.beginBackgroundTask(
            withName: backgroundTaskIdentifier
        ) {
            // Cleanup if task expires
            self.typingStateTasks[conversationId]?.cancel()
        }
        
        // Create a task to handle the update
        typingStateTasks[conversationId] = Task {
            do {
                try await updateTypingStateDirectly(
                    userId: userId,
                    conversationId: conversationId,
                    isTyping: false
                )
            } catch {
                print("Failed to update typing state in background: \(error)")
            }
            
            await UIApplication.shared.endBackgroundTask(backgroundTask)
        }
    }
    
    //        private func handleTerminatedStateUpdate(
    //            userId: String,
    //            conversationId: String
    //        ) async throws {
    //            // Use silent push notification to update state
    //            try await sendTerminationUpdateNotification(
    //                userId: userId,
    //                conversationId: conversationId
    //            )
    //        }
    //
    //        private func sendTerminationUpdateNotification(
    //            userId: String,
    //            conversationId: String
    //        ) async throws {
    //            // Implementation depends on your notification service
    //            // This would trigger a cloud function to update the state
    //
    //        }
    
    func findExistingConversation(between currentUserId: String, and otherUserId: String) async throws -> UserConversation? {
        let query = db.collection(userConversationCollectionName)
            .whereField("userId", isEqualTo: currentUserId)
            .whereField("otherUserId", isEqualTo: otherUserId)
            .limit(to: 1)
        
        let snapshot = try await query.getDocuments()
        return UserConversation.fromDictionary(snapshot.documents.first?.data() ?? [:])
    }
    
    
    func trackMessageDeliveryInRealTime(
        messageId: String,
        conversationId: String,
        recipientId: String
    ) {
        deliveryHandlers[messageId]?.remove()
        let recipientRef = db.collection(usersCollectionName).document(recipientId)
        deliveryHandlers[messageId] = recipientRef.addSnapshotListener { snapshot, _ in
            guard let snapshot = snapshot,
                  let status = snapshot.get("status") as? String,
                  status == "online" else {
                return
            }
            
            Task {
                try await self.updateMessageStatusToDelivered(
                    messageId: messageId,
                    conversationId: conversationId,
                    recipientId: recipientId
                )
                self.deliveryHandlers[messageId]?.remove()
            }
        }
    }
    
    func updateMessageStatusToDelivered(
        messageId: String,
        conversationId: String,
        recipientId: String
    ) async throws {
        let recipientRef = db.collection(usersCollectionName).document(recipientId)
        let recipient = try await recipientRef.getDocument(as: AuthUser.self)
        
        guard recipient.status == .online else {
            return
        }
        
        let messageRef = db.collection(conversationsCollectionName)
            .document(conversationId)
            .collection(usersCollectionName)
            .document(messageId)
        
        try await messageRef.updateData([
            "status": "delivered",
            "deliveredAt": FieldValue.serverTimestamp()
        ])
        
        let conversationRef = db.collection(conversationsCollectionName).document(conversationId)
        try await conversationRef.updateData([
            "lastMessage.status": "delivered"
        ])
    }
    
    func cancelDeliveryTracking(messageId: String) {
        deliveryHandlers[messageId]?.remove()
        deliveryHandlers[messageId] = nil
    }
}
