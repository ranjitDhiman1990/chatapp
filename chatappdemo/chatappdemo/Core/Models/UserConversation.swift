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
    let userName: String?
    let userImageUrl: String?
    
    let conversationId: String?
    
    let otherUserId: String?
    let otherUserName: String?
    let otherUserImageUrl: String?
    
    let lastMessage: LastMessage?
    let unreadCount: Int?
    let isTyping: Bool?
    var typingUserId: String?
    let updatedAt: Date?
    
    init(
        id: String?,
        userId: String?,
        userName: String?,
        userImageUrl: String?,
        conversationId: String?,
        otherUserId: String?,
        otherUserName: String?,
        otherUserImageUrl: String?,
        lastMessage: LastMessage?,
        unreadCount: Int?,
        isTyping: Bool?,
        typingUserId: String?,
        updatedAt: Date?
    ) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.userImageUrl = userImageUrl
        self.conversationId = conversationId
        self.otherUserId = otherUserId
        self.otherUserName = otherUserName
        self.otherUserImageUrl = otherUserImageUrl
        self.lastMessage = lastMessage
        self.unreadCount = unreadCount
        self.isTyping = isTyping
        self.typingUserId = typingUserId
        self.updatedAt = updatedAt
    }
    
    func copyWith(
        id: String? = nil,
        userId: String? = nil,
        userName: String? = nil,
        userImageUrl: String? = nil,
        conversationId: String? = nil,
        otherUserId: String? = nil,
        otherUserName: String? = nil,
        otherUserImageUrl: String? = nil,
        lastMessage: LastMessage? = nil,
        unreadCount: Int? = nil,
        isTyping: Bool? = nil,
        typingUserId: String? = nil,
        updatedAt: Date? = nil
    ) -> UserConversation {
        return UserConversation(
            id: id ?? self.id ?? "",
            userId: userId ?? self.userId ?? "",
            userName: userName ?? self.userName ?? "",
            userImageUrl: userImageUrl ?? self.userImageUrl ?? "",
            conversationId: conversationId ?? self.conversationId ?? "",
            otherUserId: otherUserId ?? self.otherUserId ?? "",
            otherUserName: otherUserName ?? self.otherUserName ?? "",
            otherUserImageUrl: otherUserImageUrl ?? self.otherUserImageUrl ?? "",
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
//        guard let data = try? JSONSerialization.data(withJSONObject: dictionary) else { return nil }
//        return try? JSONDecoder().decode(UserConversation.self, from: data)
        
        do {
                // First convert all Timestamp objects to serializable formats
                var processedDict = dictionary
                
                // Convert top-level Timestamp
                if let timestamp = dictionary["updatedAt"] as? Timestamp {
                    processedDict["updatedAt"] = [
                        "seconds": timestamp.seconds,
                        "nanoseconds": timestamp.nanoseconds
                    ]
                }
                
                // Convert nested Timestamp in lastMessage
                if var lastMessage = dictionary["lastMessage"] as? [String: Any],
                   let timestamp = lastMessage["timestamp"] as? Timestamp {
                    lastMessage["timestamp"] = [
                        "seconds": timestamp.seconds,
                        "nanoseconds": timestamp.nanoseconds
                    ]
                    processedDict["lastMessage"] = lastMessage
                }
                
                // Now safely serialize to JSON data
                let data = try JSONSerialization.data(withJSONObject: processedDict, options: [])
                
                // Configure decoder to handle the timestamp format
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .custom { decoder in
                    let container = try decoder.singleValueContainer()
                    let timestampDict = try container.decode([String: Int64].self)
                    guard let seconds = timestampDict["seconds"],
                          let nanoseconds = timestampDict["nanoseconds"] else {
                        throw DecodingError.dataCorruptedError(
                            in: container,
                            debugDescription: "Invalid timestamp format"
                        )
                    }
                    return Timestamp(seconds: seconds, nanoseconds: Int32(nanoseconds)).dateValue()
                }
                
                return try decoder.decode(UserConversation.self, from: data)
            } catch {
                print("Error decoding UserConversation: \(error.localizedDescription)")
                return nil
            }
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
        case userName
        case userImageUrl
        case conversationId
        case otherUserId
        case otherUserName
        case otherUserImageUrl
        case lastMessage
        case unreadCount
        case isTyping
        case typingUserId
        case updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        userName = try container.decode(String.self, forKey: .userName)
        userImageUrl = try container.decodeIfPresent(String.self, forKey: .userImageUrl)
        conversationId = try container.decode(String.self, forKey: .conversationId)
        otherUserId = try container.decode(String.self, forKey: .otherUserId)
        otherUserName = try container.decode(String.self, forKey: .otherUserName)
        otherUserImageUrl = try container.decodeIfPresent(String.self, forKey: .otherUserImageUrl)
        lastMessage = try container.decodeIfPresent(LastMessage.self, forKey: .lastMessage)
        unreadCount = try container.decode(Int.self, forKey: .unreadCount)
        isTyping = try container.decode(Bool.self, forKey: .isTyping)
        typingUserId = try container.decodeIfPresent(String.self, forKey: .typingUserId)
        
        // Handle Timestamp conversion
        if let timestamp = try container.decodeIfPresent(Timestamp.self, forKey: .updatedAt) {
            updatedAt = timestamp.dateValue()
        } else {
            updatedAt = nil
        }
    }
    
    // Custom encoder if you need to convert back to Firestore format
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(userName, forKey: .userName)
        try container.encodeIfPresent(userImageUrl, forKey: .userImageUrl)
        try container.encode(conversationId, forKey: .conversationId)
        try container.encode(otherUserId, forKey: .otherUserId)
        try container.encode(otherUserName, forKey: .otherUserName)
        try container.encodeIfPresent(otherUserImageUrl, forKey: .otherUserImageUrl)
        try container.encodeIfPresent(lastMessage, forKey: .lastMessage)
        try container.encode(unreadCount, forKey: .unreadCount)
        try container.encode(isTyping, forKey: .isTyping)
        try container.encodeIfPresent(typingUserId, forKey: .typingUserId)
        
        // Convert Date back to Timestamp if needed
        if let date = updatedAt {
            try container.encode(Timestamp(date: date), forKey: .updatedAt)
        }
    }
}

extension Timestamp {
    func toDictionary() -> [String: Any] {
        return [
            "seconds": self.seconds,
            "nanoseconds": self.nanoseconds
        ]
    }
}
