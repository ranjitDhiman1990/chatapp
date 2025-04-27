//
//  Conversation.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 26/04/25.
//

import Foundation
import FirebaseFirestore

struct Conversation: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    let participants: [String: Bool]?
    let lastMessage: LastMessage?
    let createdAt: Date?
    let updatedAt: Date?
    
    init(
        id: String?,
        participants: [String: Bool]?,
        lastMessage: LastMessage?,
        createdAt: Date?,
        updatedAt: Date?
    ) {
        self.id = id
        self.participants = participants
        self.lastMessage = lastMessage
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    func copyWith(
        id: String? = nil,
        participants: [String: Bool]? = nil,
        lastMessage: LastMessage? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) -> Conversation {
        return Conversation(
            id: id ?? self.id,
            participants: participants ?? self.participants,
            lastMessage: lastMessage ?? self.lastMessage,
            createdAt: createdAt ?? self.createdAt,
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
        case participants
        case lastMessage
        case createdAt
        case updatedAt
    }
    
    static func == (lhs: Conversation, rhs: Conversation) -> Bool {
        lhs.id == rhs.id
    }
}


struct LastMessage: Codable, Hashable {
    let text: String
    let senderId: String
    let timestamp: Date
}
