//
//  Message.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 23/04/25.
//

import Foundation
import FirebaseFirestore

struct Message: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    let senderId: String?
    let content: String?
    let type: MessageType?
    let timestamp: Date?
    let status: MessageStatus?
    
    init(
        id: String?,
        senderId: String?,
        content: String?,
        type: MessageType?,
        timestamp: Date?,
        status: MessageStatus?
    ) {
        self.id = id
        self.senderId = senderId
        self.content = content
        self.type = type
        self.timestamp = timestamp
        self.status = status
    }
    
    func copyWith(
        id: String? = nil,
        senderId: String? = nil,
        content: String? = nil,
        type: MessageType? = nil,
        timestamp: Date? = nil,
        status: MessageStatus? = nil
    ) -> Message {
        return Message(
            id: id ?? self.id,
            senderId: senderId ?? self.senderId,
            content: content ?? self.content,
            type: type ?? self.type,
            timestamp: timestamp ?? self.timestamp,
            status: status ?? self.status
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
    
    enum MessageType: String, Codable {
        case text, image, audio, video
    }
    
    enum MessageStatus: String, Codable {
        case sent, delivered, read
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case senderId
        case content
        case type
        case timestamp
        case status
    }
}
