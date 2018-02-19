//
//  Conversation.swift
//  App
//
//  Created by Niklas Sauer on 17.02.18.
//

import Foundation
import Vapor
import FluentSQLite

final class Conversation: Content {
    var id: Int?
    var creatorID: User.ID
    var title: String
    var creation: Date = Date()
    
    init(creatorID: User.ID, title: String) {
        self.creatorID = creatorID
        self.title = title
    }
}

extension Conversation: SQLiteModel, Migration {
    static var idKey: WritableKeyPath<Conversation, Int?> {
        return \Conversation.id
    }
    
    var directMessages: Children<Conversation, DirectMessage> {
        return children(\DirectMessage.conversationID)
    }
    
    var participants: Siblings<Conversation, User, IsParticipant> {
        return siblings()
    }
}

extension Conversation: Ownable {
    var owner: Parent<Conversation, User> {
        return parent(\Conversation.creatorID)
    }
}

extension Conversation: Parameter {
    static func make(for parameter: String, using container: Container) throws -> Future<Conversation> {
        guard let id = Int(parameter) else {
            // id must be integer
            throw Abort(.badRequest)
        }
        
        return container.requestConnection(to: .sqlite).flatMap(to: Conversation.self) { database in
            return Conversation.find(id, on: database).map(to: Conversation.self) { existingConversation in
                guard let conversation = existingConversation else {
                    // conversation not found
                    throw Abort(.notFound)
                }
                
                return conversation
            }
        }
    }
}
