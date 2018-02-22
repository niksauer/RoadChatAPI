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
    
    typealias Resource = Conversation
    typealias Result = Conversation.PublicConversation
    
    /// Returns all `Conversation`s associated to a parameterized `User`.
    func index(_ req: Request) throws -> Future<[Result]> {
        let user = try req.parameter(User.self).await(on: req)
        try req.user().checkOwnership(for: user, on: req)
        
        return try user.getConversations(on: req).map(to: [Result].self) { conversations in
            var fullConversations = [Result]()
            
            for conversation in conversations {
                let newestMessage = try conversation.getNewestMessage(on: req).await(on: req)
                fullConversations.append(try conversation.publicConversation(newestMessage: newestMessage))
            }
            
            return fullConversations
        }
    }

    /// Saves a new `Conversation` to the database.
    func create(_ req: Request) throws -> Future<Result> {
        let conversationRequest = try ConversationRequest.extract(from: req)
        let creator = try req.user()
        
        var participants = [creator]
        var invalidParticipants = [Int]()
        
        for participant in conversationRequest.participants {
            guard try participant != creator.requireID() else {
                continue
            }
            
            guard let receipient = try User.query(on: req).filter(\User.id == participant).first().await(on: req) else {
                invalidParticipants.append(participant)
                continue
            }
            
            participants.append(receipient)
        }
    
        guard invalidParticipants.isEmpty else {
            throw ConversationFail.invalidParticipants(invalidParticipants)
        }

        guard participants.count > 1 else {
            throw ConversationFail.minimumParticipants
        }
        
        return Conversation(creatorID: try creator.requireID(), title: conversationRequest.title).create(on: req).map(to: Result.self) { conversation in
            // add participants to conversation via pivot table
            for participant in participants {
                let participation = try conversation.participations.attach(participant, on: req).await(on: req)
                
                if try participant.requireID() == creator.requireID() {
                    // default approval status of creator to approved
                    participation.approvalStatus = ApprovalStatus.accepted.rawValue
                    _ = participation.save(on: req)
                }
            }
            
            return try conversation.publicConversation(newestMessage: nil)
        }
    }
    
    /// Returns a parameterized `Conversation`.
    func get(_ req: Request) throws -> Future<Result> {
        let conversation = try req.parameter(Resource.self).await(on: req)
        try req.checkParticipation(in: conversation)
        
        return try conversation.getNewestMessage(on: req).map(to: Result.self) { newestMessage in
            return try conversation.publicConversation(newestMessage: newestMessage)
        }
    }
    
    /// Deletes a parameterized `Conversation` from the `Conversation`s associated to a `User`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        let conversation = try req.parameter(Resource.self).await(on: req)
        try req.checkParticipation(in: conversation)
        
        return conversation.participations.detach(try req.user(), on: req).flatMap(to: HTTPStatus.self) { _ in
            return try conversation.participations.query(on: req).count().flatMap(to: HTTPStatus.self) { count in
                if count == 0 {
                    // delete conversation if no more participations
                    return conversation.delete(on: req).transform(to: .ok)
                } else {
                    return Future(HTTPStatus.ok)
                }
            }
        }
    }
    
    /// Returns all `DirectMessage`s associated to a parameterized `Conversation`.
    func getMessages(_ req: Request) throws -> Future<[DirectMessage.PublicDirectMessage]> {
        let conversation = try req.parameter(Resource.self).await(on: req)
        try req.checkParticipation(in: conversation)
        
        return try conversation.getMessages(on: req).map(to: [DirectMessage.PublicDirectMessage].self) { messages in
            return try messages.map({ try $0.publicDirectMessage() })
        }
    }
    
    /// Saves a new `DirectMessage` associated to a parameterized `Conversation` to the database.
    func createMessage(_ req: Request) throws -> Future<HTTPStatus> {
        let conversation = try req.parameter(Resource.self).await(on: req)
        try req.checkParticipation(in: conversation)
        
        let messageRequest = try DirectMessageRequest.extract(from: req)
        
        return try DirectMessage(senderID: req.user().requireID(), conversationID: conversation.requireID(), messageRequest: messageRequest).create(on: req).transform(to: .ok)
    }
    
    /// Returns all `User`s associated to a parameterized `Conversation`.
    func getParticipants(_ req: Request) throws -> Future<[Participation.PublicParticipant]> {
        let conversation = try req.parameter(Resource.self).await(on: req)
        try req.checkParticipation(in: conversation)
        
        return try conversation.getParticipations(on: req).map(to: [Participation.PublicParticipant].self) { participations in
            return participations.map({ $0.publicParticipant() })
        }
    }
    
    /// Sets the `ApprovalStatus` for a parameterized `Conversation` to `.accepted`.
    func acceptConversation(_ req: Request) throws -> Future<HTTPStatus> {
        return try setApprovalStatus(.accepted, on: req)
    }
    
    /// Sets the `ApprovalStatus` for a parameterized `Conversation` to `.denied`.
    func denyConversation(_ req: Request) throws -> Future<HTTPStatus> {
        return try setApprovalStatus(.denied, on: req)
    }
    
    private func setApprovalStatus(_ status: ApprovalStatus, on req: Request) throws -> Future<HTTPStatus> {
        let conversation = try req.parameter(Resource.self).await(on: req)
        
        return try req.getParticipation(in: conversation).flatMap(to: HTTPStatus.self) { participation in
            participation.approvalStatus = status.rawValue
            return participation.save(on: req).transform(to: .ok)
        }
    }
    
}

