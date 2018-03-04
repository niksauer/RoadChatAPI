//
//  Conversation.swift
//  App
//
//  Created by Niklas Sauer on 17.02.18.
//

import Foundation
import Vapor
import FluentSQLite
import RoadChatKit

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

extension Conversation {
    func publicConversation(newestMessage: DirectMessage?) throws -> PublicConversation {
        return try PublicConversation(conversation: self, newestMessage: newestMessage)
    }
    
    struct PublicConversation: Content {
        let id: Int
        let creatorID: User.ID
        let title: String
        let creation: Date
        let newestMessage: DirectMessage.PublicDirectMessage?
        
        init(conversation: Conversation, newestMessage: DirectMessage?) throws {
            self.id = try conversation.requireID()
            self.creatorID = conversation.creatorID
            self.title = conversation.title
            self.creation = conversation.creation
            self.newestMessage = try newestMessage?.publicDirectMessage()
        }
    }
}

extension Conversation: SQLiteModel, Migration {
    static var idKey: WritableKeyPath<Conversation, Int?> {
        return \Conversation.id
    }
    
    var messages: Children<Conversation, DirectMessage> {
        return children(\DirectMessage.conversationID)
    }
    
    var participations: Siblings<Conversation, User, Participation> {
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

extension Conversation {
    func getNewestMessage(on req: Request) throws -> Future<DirectMessage?> {
        return try messages.query(on: req).sort(\DirectMessage.time, .descending).first()
    }
    
    func getMessages(on req: Request) throws -> Future<[DirectMessage]> {
        return try messages.query(on: req).all()
    }
    
    func getParticipations(on req: Request) throws -> Future<[Participation]> {
        return Participation.query(on: req).filter(try \Participation.conversationID == self.requireID()).all()
    }
}
