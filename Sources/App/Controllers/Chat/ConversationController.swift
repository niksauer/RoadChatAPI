//
//  ConversationController.swift
//  App
//
//  Created by Niklas Sauer on 18.02.18.
//

import Foundation
import Vapor
import Fluent

/// Controls basic CRUD operations on `Conversation`s.
final class ConversationController {
    
    /// Returns all `Conversation`s associated to a parameterized `User`.
    func index(_ req: Request) throws -> Future<[Conversation.PublicConversation]> {
        let user = try req.parameter(User.self).await(on: req)
        try req.checkOwnership(for: user)
        
        return try user.getConversations(on: req).flatMap(to: [Conversation.PublicConversation].self) { conversations in
            var fullConversations = [Conversation.PublicConversation]()
            
            for conversation in conversations {
                let newestMessage = try conversation.getNewestMessage(on: req).await(on: req)
                fullConversations.append(try conversation.publicConversation(newestMessage: newestMessage))
            }
            
            return Future(fullConversations)
        }
    }

    /// Saves a new `Conversation` to the database.
    func create(_ req: Request) throws -> Future<Conversation.PublicConversation> {
        let conversationRequest = try ConversationRequest.extract(from: req)
        
        var participants = [try req.user()]
        var invalidParticipants = [Int]()
        
        for userID in conversationRequest.participants {
            if let user = try User.query(on: req).filter(\User.id == userID).first().await(on: req) {
                participants.append(user)
            } else {
                // participant not found
                invalidParticipants.append(userID)
            }
        }
        
        guard invalidParticipants.isEmpty else {
            throw ConversationFail.invalidParticipants(invalidParticipants)
        }

        return Conversation(creatorID: try req.user().requireID(), title: conversationRequest.title).create(on: req).map(to: Conversation.PublicConversation.self) { conversation in
            // add participants to conversation via pivot table
            for participant in participants {
                _ = conversation.participants.attach(participant, on: req)
            }
            
            return try conversation.publicConversation(newestMessage: nil)
        }
    }
    
    /// Returns a parameterized `Conversation`.
    func get(_ req: Request) throws -> Future<Conversation.PublicConversation> {
        let conversation = try req.parameter(Conversation.self).await(on: req)
        try req.checkParticipation(in: conversation)
        
        return try conversation.getNewestMessage(on: req).map(to: Conversation.PublicConversation.self) { newestMessage in
            return try conversation.publicConversation(newestMessage: newestMessage)
        }
    }
    
    /// Deletes a parameterized `Conversation` from the `Conversation`s associated to a `User`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        let conversation = try req.parameter(Conversation.self).await(on: req)
        try req.checkParticipation(in: conversation)
        
        return conversation.participants.detach(try req.user(), on: req).transform(to: .ok)
    }
    
    /// Returns all `DirectMessage`s associated to a parameterized `Conversation`.
    func getMessages(_ req: Request) throws -> Future<[DirectMessage.PublicDirectMessage]> {
        let conversation = try req.parameter(Conversation.self).await(on: req)
        try req.checkParticipation(in: conversation)
        
        return try conversation.getMessages(on: req).map(to: [DirectMessage.PublicDirectMessage].self) { messages in
            return try messages.map({ try $0.publicDirectMessage() })
        }
    }
    
    /// Saves a new `DirectMessage` associated to a parameterized `Conversation` to the database.
    func createMessage(_ req: Request) throws -> Future<HTTPStatus> {
        let conversation = try req.parameter(Conversation.self).await(on: req)
        try req.checkParticipation(in: conversation)
        
        let messageRequest = try DirectMessageRequest.extract(from: req)
        
        return try DirectMessage(senderID: req.user().requireID(), conversationID: conversation.requireID(), messageRequest: messageRequest).create(on: req).transform(to: .ok)
    }
    
    /// Returns all `User`s associated to a parameterized `Conversation`.
    func getParticipants(_ req: Request) throws -> Future<[User.PublicUser]> {
        let conversation = try req.parameter(Conversation.self).await(on: req)
        try req.checkParticipation(in: conversation)
        
        return try conversation.getParticipants(on: req).map(to: [User.PublicUser].self) { participants in
            return try participants.map({ try $0.publicUser() })
        }
    }
    
}

extension Request {
    /// Checks participation in a `Conversaton` according to the supplied `Token`.
    func checkParticipation(in conversation: Conversation) throws {
        guard try conversation.participants.isAttached(try self.user(), on: self).await(on: self) else {
            // authenticated user is not a participant
            throw Abort(.unauthorized)
        }
    }
}

