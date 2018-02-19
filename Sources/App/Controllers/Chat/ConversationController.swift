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
    func index(_ req: Request) throws -> Future<[Conversation]> {
        let user = try req.parameter(User.self).await(on: req)
        try req.checkOwnership(for: user)
        
        // TODO: add conversation excerpts to result set
        
        return try user.conversations.query(on: req).all()
    }

    /// Saves a new `Conversation` to the database.
    func create(_ req: Request) throws -> Future<Conversation> {
        let conversationRequest = try ConversationRequest.extract(from: req)
        let user = try req.user()
        
        var participants = [user]
        
        for userID in conversationRequest.participants {
            guard let user = try User.query(on: req).filter(\User.id == userID).first().await(on: req) else {
                // user not found
                throw ConversationFail.invalidParticipants
            }
            
            participants.append(user)
        }

        return try Conversation(creatorID: user.requireID(), title: conversationRequest.title).create(on: req).map(to: Conversation.self) { conversation in
            for participant in participants {
                _ = conversation.participants.attach(participant, on: req)
            }
            
            return conversation
        }

    }
    
    /// Returns a parameterized `Conversation`.
    func get(_ req: Request) throws -> Future<Conversation> {
        return try req.parameter(Conversation.self).map(to: Conversation.self) { conversation in
            guard try conversation.participants.isAttached(try req.user(), on: req).await(on: req) else {
                // authenticated user is not a participant
                throw Abort(.unauthorized)
            }
            
            return conversation
        }
    }
    
    /// Deletes a parameterized `Conversation` from the `Conversation`s associated to a User.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameter(Conversation.self).flatMap(to: HTTPStatus.self) { conversation in
            guard try conversation.participants.isAttached(try req.user(), on: req).await(on: req) else {
                // authenticated user is not a participant
                throw Abort(.unauthorized)
            }
            
            return conversation.participants.detach(try req.user(), on: req).transform(to: .ok)
        }
    }
    
    /// Returns all `DirectMessage`s associated to a parameterized `Conversation`.
    func getMessages(_ req: Request) throws -> Future<[DirectMessage]> {
        return try req.parameter(Conversation.self).flatMap(to: [DirectMessage].self) { conversation in
            return try conversation.directMessages.query(on: req).all()
        }
    }
    
    /// Saves a new `DirectMessage` to the database.
    func createMessage(_ req: Request) throws -> Future<HTTPStatus> {
        let messageRequest = try DirectMessageRequest.extract(from: req)
        let user = try req.user()
        
        return try req.parameter(Conversation.self).flatMap(to: HTTPStatus.self) { conversation in
            guard try conversation.participants.isAttached(user, on: req).await(on: req) else {
                // authenticated user is not a participant
                throw Abort(.unauthorized)
            }
            
            return try DirectMessage(senderID: user.requireID(), conversationID: conversation.requireID(), time: messageRequest.time, message: messageRequest.message).create(on: req).transform(to: .ok)
        }
    }
    
}
