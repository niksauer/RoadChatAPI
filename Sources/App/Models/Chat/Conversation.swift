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

extension Conversation: MySQLModel, Migration {
    public static var idKey: WritableKeyPath<Conversation, Int?> {
        return \Conversation.id
    }
    
    public static var entity: String {
        return "Conversation"
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
        
        return container.newConnection(to: .mysql).flatMap(to: Conversation.self) { database in
            return try Conversation.find(id, on: database).map(to: Conversation.self) { existingConversation in
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
    func publicConversation(on req: Request) throws -> Future<Conversation.PublicConversation> {
        return try self.getNewestMessage(on: req).flatMap(to: Conversation.PublicConversation.self) { newestMessage in
            return try self.getParticipants(on: req).map(to: Conversation.PublicConversation.self) { participants in
                return try self.publicConversation(newestMessage: newestMessage, participants: participants)
            }
        }
        
    }
    
    func getNewestMessage(on req: Request) throws -> Future<DirectMessage?> {
        return try messages.query(on: req).sort(\DirectMessage.time, .descending).first()
    }
    
    func getMessages(on req: Request) throws -> Future<[DirectMessage]> {
        return try messages.query(on: req).all()
    }
    
    func getParticipations(on req: Request) throws -> Future<[Participation]> {
        return Participation.query(on: req).filter(try \Participation.conversationID == self.requireID()).all()
    }
    
    func getParticipants(on req: Request) throws -> Future<[Participation.PublicParticipant]> {
        return try self.getParticipations(on: req).flatMap(to: [Participation.PublicParticipant].self) { participations in
            return try participations.map { participant -> EventLoopFuture<Participation.PublicParticipant?> in
                
                return User.query(on: req).filter(try \User.id == participant.userID).first().flatMap(to: Participation.PublicParticipant?.self) { user in
                    guard let user = user else {
                        return Future.map(on: req) { nil }
                    }
                    
                    return try user.publicUser(on: req).map(to: Participation.PublicParticipant?.self) { publicUser in
                        return participant.publicParticipant(user: publicUser )
                    }
                }
            }.map(to: [Participation.PublicParticipant].self, on: req) { participants in
                return participants.compactMap { $0 }
            }
        }
    }
}

extension Conversation.PublicConversation: Content {}
