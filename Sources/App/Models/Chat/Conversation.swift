//
//  Conversation.swift
//  App
//
//  Created by Niklas Sauer on 17.02.18.
//

import Foundation
import Vapor
import FluentMySQL
import RoadChatKit

extension Conversation: SQLiteModel, Migration {
    public static var idKey: WritableKeyPath<Conversation, Int?> {
        return \Conversation.id
    }
    
    static var entity: String {
        return "conversation"
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
    public static func make(for parameter: String, using container: Container) throws -> Future<Conversation> {
        guard let id = Int(parameter) else {
            // id must be integer
            throw Abort(.badRequest)
        }
        
        return container.requestConnection(to: .mysql).flatMap(to: Conversation.self) { database in
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

extension Conversation.PublicConversation: Content {}
