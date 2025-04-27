//
//  UserConversation.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 26/04/25.
//

import Foundation
import FirebaseFirestore

struct UserConversation: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    let userId: String?
    let conversationId: String?
    let otherUserId: String?
    let lastMessage: LastMessage?
    let unreadCount: Int?
    let isTyping: Bool?
    var typingUserId: String?
    let updatedAt: Date?
    
    init(
        id: String?,
        userId: String?,
        conversationId: String?,
        otherUserId: String?,
        lastMessage: LastMessage?,
        unreadCount: Int?,
        isTyping: Bool?,
        typingUserId: String?,
        updatedAt: Date?
    ) {
        self.id = id
        self.userId = userId
        self.conversationId = conversationId
        self.otherUserId = otherUserId
        self.lastMessage = lastMessage
        self.unreadCount = unreadCount
        self.isTyping = isTyping
        self.typingUserId = typingUserId
        self.updatedAt = updatedAt
    }
    
    func copyWith(
        id: String? = nil,
        userId: String? = nil,
        conversationId: String? = nil,
        otherUserId: String? = nil,
        lastMessage: LastMessage? = nil,
        unreadCount: Int? = nil,
        isTyping: Bool? = nil,
        typingUserId: String? = nil,
        updatedAt: Date? = nil
    ) -> UserConversation {
        return UserConversation(
            id: id ?? self.id ?? "",
            userId: userId ?? self.userId ?? "",
            conversationId: conversationId ?? self.conversationId ?? "",
            otherUserId: otherUserId ?? self.otherUserId ?? "",
            lastMessage: lastMessage ?? self.lastMessage,
            unreadCount: unreadCount ?? self.unreadCount,
            isTyping: isTyping ?? self.isTyping,
            typingUserId: typingUserId ?? self.typingUserId,
            updatedAt: updatedAt ?? self.updatedAt
        )
    }
    
    func toDictionary() -> [String: Any]? {
        return try? Firestore.Encoder().encode(self)
    }
    
    static func fromDictionary(_ dictionary: [String: Any]) -> UserConversation? {
        guard let data = try? JSONSerialization.data(withJSONObject: dictionary) else { return nil }
        return try? JSONDecoder().decode(UserConversation.self, from: data)
    }
    
    func toJSON() -> Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            return try encoder.encode(self)
        } catch {
            debugPrint("Error encoding to JSON: \(error)")
            return nil
        }
    }
    
    func toJSONString() -> String? {
        guard let data = toJSON() else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case conversationId
        case otherUserId
        case lastMessage
        case unreadCount
        case isTyping
        case typingUserId
        case updatedAt
    }
}
