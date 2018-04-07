//
//  CommunityController.swift
//  App
//
//  Created by Niklas Sauer on 06.02.18.
//

import Foundation
import Vapor
import Fluent
import RoadChatKit

/// Controls basic CRUD operations on `CommunityMessage`s.
final class CommunityController {
    
    typealias Resource = CommunityMessage
    typealias Result = CommunityMessage.PublicCommunityMessage
    
    /// Returns all `CommunityMessage`s.
    func index(_ req: Request) throws -> Future<[Result]> {
        return CommunityMessage.query(on: req).all().flatMap(to: [Result].self) { messages in
            return try messages.map {
                return try $0.publicCommunityMessage(on: req)
            }.map(to: [Result].self, on: req) { messages in
                return messages
            }
        }
    }
    
    /// Saves a new `CommunityMessage` to the database.
    func create(_ req: Request) throws -> Future<Result> {
        return try CommunityMessageRequest.extract(from: req).flatMap(to: Result.self) { communityMessageRequest in
            let creator = try req.user()
            
            return Location(communityMessageRequest: communityMessageRequest).create(on: req).flatMap(to: Result.self) { location in
                return CommunityMessage(senderID: try creator.requireID(), locationID: try location.requireID(), communityRequest: communityMessageRequest).create(on: req).flatMap(to: Result.self) { message in
                    return try creator.donate(.upvote, to: message, on: req).flatMap(to: Result.self) { _ in
                        return try message.publicCommunityMessage(on: req)
                    }
                }
            }
        }
    }
    
    /// Returns a parameterized `CommunityMessage`.
    func get(_ req: Request) throws -> Future<Result> {
        return try req.parameter(Resource.self).flatMap(to: Result.self) { message in
            return try message.publicCommunityMessage(on: req)
        }
    }
    
    /// Deletes a parameterized `CommunityMessage`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameter(Resource.self).flatMap(to: HTTPStatus.self) { communityMessage in
            try req.user().checkOwnership(for: communityMessage, on: req)
            return communityMessage.delete(on: req).transform(to: .ok)
        }
    }
    
    /// Upvotes a parameterized `CommunityMessage`.
    func upvote(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameter(Resource.self).flatMap(to: HTTPStatus.self) { message in
            return try req.user().donate(.upvote, to: message, on: req).transform(to: .ok)
        }
    }
    
    /// Downvotes a parameterized `CommunityMessage`.
    func downvote(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameter(Resource.self).flatMap(to: HTTPStatus.self) { message in
            return try req.user().donate(.downvote, to: message, on: req).transform(to: .ok)
        }
    }

}
