//
//  ConversationController.swift
//  App
//
//  Created by Niklas Sauer on 18.02.18.
//

import Foundation
import Vapor
import Fluent
import GeoSwift
import WebSocket
import RoadChatKit

/// Controls basic CRUD operations on `Conversation`s.
final class ConversationController {
    
    typealias Resource = Conversation
    typealias Result = Conversation.PublicConversation
    
    var activeChatrooms = [Chatroom]()
    
    /// Returns all `Conversation`s associated to a parameterized `User`.
    func index(_ req: Request) throws -> Future<[Result]> {
        return try req.parameter(User.self).flatMap(to: [Result].self) { user in
            try req.user().checkOwnership(for: user, on: req)
            
            return try user.getConversations(on: req).flatMap(to: [Result].self) { conversations in
                return try conversations.map { conversation in
                    return try conversation.getNewestMessage(on: req).map(to: Result.self) { newestMessage in
                        return try conversation.publicConversation(newestMessage: newestMessage)
                    }
                }.map(to: [Result].self, on: req) { fullConversations in
                    return fullConversations
                }
            }
        }
    }

    let maxDistance = 500.0
    
    /// Returns all `User`s which are within 500m distance of a tokenized `User`.
    func getNearbyUsers(_ req: Request) throws -> Future<[User.PublicUser]> {
        let requestor = try req.user()
        
        return try requestor.getLocation(on: req).flatMap(to: [User.PublicUser].self) { location in
            guard let requestorLocation = location else {
                throw ConversationFail.noAssociatedLocation
            }
            
            let requestorGeoLocation = try GeoCoordinate2D(latitude: requestorLocation.latitude, longitude: requestorLocation.longitude)
            
            return User.query(on: req).filter(try \User.id != requestor.requireID()).all().flatMap(to: [User.PublicUser].self) { users in
                return try users.map { user in
                    return try user.getPrivacy(on: req).flatMap(to: User.PublicUser?.self) { privacy in
                        guard privacy.shareLocation else {
                            return Future.map(on: req) { nil }
                        }
                        
                        return try user.getLocation(on: req).flatMap(to: User.PublicUser?.self) { location in
                            guard let location = location else {
                                return Future.map(on: req) { nil }
                            }
                            
                            let geoLocation = try GeoCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                            
                            guard requestorGeoLocation.distance(from: geoLocation) <= self.maxDistance else {
                                return Future.map(on: req) { nil }
                            }
                            
                            return Future.map(on: req) { try user.publicUser(isOwner: false, location: location) }
                        }
                    }
                }.map(to: [User.PublicUser].self, on: req) { users in
                    return users.compactMap({ return $0 })
                }
            }
        }
    }
    
    /// Saves a new `Conversation` to the database.
    func create(_ req: Request) throws -> Future<Result> {
        return try ConversationRequest.extract(from: req).flatMap(to: Result.self) { conversationRequest in
            let creator = try req.user()

            var invalidParticipants = [Int]()
            
            return try conversationRequest.participants.map { participant -> EventLoopFuture<User?> in
                guard try participant != creator.requireID() else {
                    return Future.map(on: req) { nil }
                }
                
                return try User.query(on: req).filter(\User.id == participant).first().flatMap(to: User?.self) { receipient in
                    guard let receipient = receipient else {
                        invalidParticipants.append(participant)
                        return Future.map(on: req) { nil }
                    }
                    
                    return Future.map(on: req) { receipient }
                }
            }.flatMap(to: Result.self, on: req) { participants in
                guard invalidParticipants.isEmpty else {
                    throw ConversationFail.invalidParticipants(invalidParticipants)
                }
                
                guard participants.count > 1 else {
                    throw ConversationFail.minimumParticipants
                }
                    
                var participants = participants.compactMap { return $0 }
                participants.append(creator)
                
                return Conversation(creatorID: try creator.requireID(), title: conversationRequest.title).create(on: req).flatMap(to: Result.self) { conversation in
                    // add participants to conversation via pivot table
                    return participants.map { participant in
                        return conversation.participations.attach(participant, on: req).flatMap(to: Participation.self) { participation in
                            guard try participant.requireID() == creator.requireID() else {
                                return Future.map(on: req) { participation }
                            }
                            
                            // default approval status of creator to approved
                            participation.status = ApprovalType.accepted.rawValue
                            return participation.save(on: req)
                        }
                    }.map(to: Result.self, on: req) { participations in
                            return try conversation.publicConversation(newestMessage: nil)
                    }
                }
            }
        }
    }
    
    /// Returns a parameterized `Conversation` including the newest `DirectMessage` as an excerpt.
    func get(_ req: Request) throws -> Future<Result> {
        return try req.parameter(Resource.self).flatMap(to: Result.self) { conversation in
            try req.user().checkParticipation(in: conversation, on: req)
            
            return try conversation.getNewestMessage(on: req).map(to: Result.self) { newestMessage in
                return try conversation.publicConversation(newestMessage: newestMessage)
            }
        }
    }
    
    /// Opens a WebSocket for a parameterized `Conversation`.
    func liveChat(websocket: WebSocket, req: Request) throws -> Void {
        // timer to keep connection alive
//        var pingTimer: DispatchSourceTimer?
//        pingTimer = DispatchSource.makeTimerSource()
//        pingTimer?.schedule(deadline: .now(), repeating: .seconds(25))
//        pingTimer?.setEventHandler(handler: { websocket.ping() })
//        pingTimer?.resume()

        let user = try req.user()
        let userID = try user.requireID()

        let conversation = try req.parameter(Resource.self).wait()
        try user.checkParticipation(in: conversation, on: req)

        let chatroom: Chatroom

        if let existingChatroom = try activeChatrooms.first(where: { try $0.conversationID == conversation.requireID() }) {
            chatroom = existingChatroom
        } else {
            chatroom = Chatroom(conversationID: try conversation.requireID())
            activeChatrooms.append(chatroom)
        }

        if let priorSocket = chatroom.connections[userID] {
            // close and notify user that prior session will be closed
            priorSocket.close()
            websocket.notify(event: .existingSession)
        }

        // set user session to this socket and notify chatroom that user is online
        chatroom.connections[userID] = websocket
        chatroom.notify(event: .online(userID: userID))

        websocket.onText { message in
            chatroom.send(senderID: userID, message: message)
        }

        websocket.onClose {
//            pingTimer?.cancel()
//            pingTimer = nil

            chatroom.connections.removeValue(forKey: userID)
            chatroom.notify(event: .offline(userID: userID))
        }
    }
    
    /// Deletes a parameterized `Conversation` from the `Conversation`s associated to a `User`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameter(Resource.self).flatMap(to: HTTPStatus.self) { conversation in
            try req.user().checkParticipation(in: conversation, on: req)
            
            return conversation.participations.detach(try req.user(), on: req).flatMap(to: HTTPStatus.self) { _ in
                return try conversation.participations.query(on: req).count().flatMap(to: HTTPStatus.self) { count in
                    if count == 0 {
                        // delete conversation if no more participations
                        return conversation.delete(on: req).transform(to: .ok)
                    } else {
                        return Future.map(on: req) { HTTPStatus.ok }
                    }
                }
            }
        }
    }
    
    /// Returns all `DirectMessage`s associated to a parameterized `Conversation`.
    func getMessages(_ req: Request) throws -> Future<[DirectMessage.PublicDirectMessage]> {
        return try req.parameter(Resource.self).flatMap(to: [DirectMessage.PublicDirectMessage].self) { conversation in
            try req.user().checkParticipation(in: conversation, on: req)
            
            return try conversation.getMessages(on: req).map(to: [DirectMessage.PublicDirectMessage].self) { messages in
                return try messages.map({ try $0.publicDirectMessage() })
            }
        }
    }
    
    /// Saves a new `DirectMessage` associated to a parameterized `Conversation` to the database.
    func createMessage(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameter(Resource.self).flatMap(to: HTTPStatus.self) { conversation in
            try req.user().checkParticipation(in: conversation, on: req)
            
            return try DirectMessageRequest.extract(from: req).flatMap(to: HTTPStatus.self) { messageRequest in
                return try DirectMessage(senderID: req.user().requireID(), conversationID: conversation.requireID(), messageRequest: messageRequest).create(on: req).transform(to: .ok)
            }
        }
    }
    
    /// Returns all `User`s associated to a parameterized `Conversation`.
    func getParticipants(_ req: Request) throws -> Future<[Participation.PublicParticipant]> {
        return try req.parameter(Resource.self).flatMap(to: [Participation.PublicParticipant].self) { conversation in
            try req.user().checkParticipation(in: conversation, on: req)
            
            return try conversation.getParticipations(on: req).map(to: [Participation.PublicParticipant].self) { participations in
                return participations.map({ $0.publicParticipant() })
            }
        }
    }
    
    /// Sets the `ApprovalStatus` for a parameterized `Conversation` to `.accepted`.
    func acceptConversation(_ req: Request) throws -> Future<HTTPStatus> {
        return try setStatus(.accepted, on: req)
    }
    
    /// Sets the `ApprovalStatus` for a parameterized `Conversation` to `.denied`.
    func denyConversation(_ req: Request) throws -> Future<HTTPStatus> {
        return try setStatus(.denied, on: req)
    }
    
    private func setStatus(_ status: ApprovalType, on req: Request) throws -> Future<HTTPStatus> {
        return try req.parameter(Resource.self).flatMap(to: HTTPStatus.self) { conversation in
            return try req.user().getParticipation(in: conversation, on: req).flatMap(to: HTTPStatus.self) { participation in
                participation.status = status.rawValue
                return participation.save(on: req).transform(to: .ok)
            }
        }
    }
    
}
