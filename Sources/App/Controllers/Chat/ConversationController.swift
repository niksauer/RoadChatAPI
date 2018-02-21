//
//  ConversationController.swift
//  App
//
//  Created by Niklas Sauer on 18.02.18.
//

import Foundation
import Vapor
import Fluent
import WebSocket

/// Controls basic CRUD operations on `Conversation`s.
final class ConversationController {
    
    var activeChatrooms = [Chatroom]()
    
    /// Returns all `Conversation`s associated to a parameterized `User`.
    func index(_ req: Request) throws -> Future<[Conversation.PublicConversation]> {
        let user = try req.parameter(User.self).await(on: req)
        try req.user().checkOwnership(for: user, on: req)
        
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
        let creator = try req.user()
        
        var participants = [creator]
        
        guard let receipient = try User.query(on: req).filter(\User.id == conversationRequest.participants).first().await(on: req) else {
            throw ConversationFail.invalidParticipants([conversationRequest.participants])
        }
        
        participants.append(receipient)

        return Conversation(creatorID: try creator.requireID(), title: conversationRequest.title).create(on: req).map(to: Conversation.PublicConversation.self) { conversation in
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
    func get(_ req: Request) throws -> Future<Conversation.PublicConversation> {
        let conversation = try req.parameter(Conversation.self).await(on: req)
        try req.user().checkParticipation(in: conversation, on: req)
        
        return try conversation.getNewestMessage(on: req).map(to: Conversation.PublicConversation.self) { newestMessage in
            return try conversation.publicConversation(newestMessage: newestMessage)
        }
    }
    
    /// Opens a WebSocket for a parameterized `Conversation`.
    func liveChat(_ req: Request, _ websocket: WebSocket) throws -> Void {
        do {
            let user = try req.user()
            let userID = try user.requireID()
            let conversation = try req.parameter(Conversation.self).await(on: req)
            
            try user.checkParticipation(in: conversation, on: req)
            
            let chatroom: Chatroom
            
            if let existingChatroom = try activeChatrooms.first(where: { try $0.conversationID == conversation.requireID() }) {
                chatroom = existingChatroom
            } else {
                chatroom = Chatroom(conversationID: try conversation.requireID())
                activeChatrooms.append(chatroom)
            }
            
            // use timer to keep connection alive
            var pingTimer: DispatchSourceTimer?
            pingTimer = DispatchSource.makeTimerSource()
            pingTimer?.schedule(deadline: .now(), repeating: .seconds(25))
            pingTimer?.setEventHandler(handler: { websocket.ping() })
            pingTimer?.resume()
            
            if let priorSocket = chatroom.connections[userID] {
                // close and notify user that prior session will be closed
                priorSocket.close()
                websocket.notify(event: .existingSession)
            }
            
            // set user session to this socket and notify chatroom that user is online
            chatroom.connections[userID] = websocket
            chatroom.notify(event: .online(userID: userID))
            
            websocket.onString { websocket, message in
                chatroom.send(senderID: userID, message: message)
            }
            
            websocket.onClose { websocket, _  in
                pingTimer?.cancel()
                pingTimer = nil
                
                chatroom.connections.removeValue(forKey: userID)
                chatroom.notify(event: .offline(userID: userID))
            }
        } catch {
            websocket.close()
        }
    }
    
    /// Deletes a parameterized `Conversation` from the `Conversation`s associated to a `User`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        let conversation = try req.parameter(Conversation.self).await(on: req)
        try req.user().checkParticipation(in: conversation, on: req)
        
        return conversation.participations.detach(try req.user(), on: req).transform(to: .ok)
    }
    
    /// Returns all `DirectMessage`s associated to a parameterized `Conversation`.
    func getMessages(_ req: Request) throws -> Future<[DirectMessage.PublicDirectMessage]> {
        let conversation = try req.parameter(Conversation.self).await(on: req)
        try req.user().checkParticipation(in: conversation, on: req)
        
        return try conversation.getMessages(on: req).map(to: [DirectMessage.PublicDirectMessage].self) { messages in
            return try messages.map({ try $0.publicDirectMessage() })
        }
    }
    
    /// Saves a new `DirectMessage` associated to a parameterized `Conversation` to the database.
    func createMessage(_ req: Request) throws -> Future<HTTPStatus> {
        let conversation = try req.parameter(Conversation.self).await(on: req)
        try req.user().checkParticipation(in: conversation, on: req)
        
        let messageRequest = try DirectMessageRequest.extract(from: req)
        
        return try DirectMessage(senderID: req.user().requireID(), conversationID: conversation.requireID(), messageRequest: messageRequest).create(on: req).transform(to: .ok)
    }
    
    /// Returns all `User`s associated to a parameterized `Conversation`.
    func getParticipants(_ req: Request) throws -> Future<[Participation.PublicParticipant]> {
        let conversation = try req.parameter(Conversation.self).await(on: req)
        try req.user().checkParticipation(in: conversation, on: req)
        
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
        let conversation = try req.parameter(Conversation.self).await(on: req)
        
        return try req.user().getParticipation(in: conversation, on: req).flatMap(to: HTTPStatus.self) { participation in
            participation.approvalStatus = status.rawValue
            return participation.save(on: req).transform(to: .ok)
        }
    }
    
}
