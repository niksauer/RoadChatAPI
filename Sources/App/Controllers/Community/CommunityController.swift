//
//  CommunityController.swift
//  App
//
//  Created by Niklas Sauer on 06.02.18.
//

import Foundation
import Vapor
import Fluent

/// Controls basic CRUD operations on `CommunityMessage`s.
final class CommunityController {
    
    typealias Resource = CommunityMessage
    typealias Result = CommunityMessage.PublicCommunityMessage
    
    /// Returns all `CommunityMessage`s.
    func index(_ req: Request) throws -> Future<[Result]> {
        return CommunityMessage.query(on: req).all().map(to: [Result].self) { messages in
            return try messages.map({ try $0.publicCommunityMessage(on: req) })
        }
    }
    
    /// Saves a new `CommunityMessage` to the database.
    func create(_ req: Request) throws -> Future<Result> {
        let communityMessageRequest = try CommunityMessageRequest.extract(from: req)
        let creator = try req.user()
        
        return CommunityMessage(senderID: try creator.requireID(), communityRequest: communityMessageRequest).create(on: req).flatMap(to: Result.self) { message in
            return message.interactions.attach(creator, on: req).map(to: Result.self) { interaction in
                interaction.karma = KarmaType.upvote.rawValue
                _ = interaction.save(on: req)
                return try message.publicCommunityMessage(on: req)
            }
        }
    }
    
    /// Returns a parameterized `CommunityMessage`.
    func get(_ req: Request) throws -> Future<Result> {
        return try req.parameter(Resource.self).map(to: Result.self) { message in
            return try message.publicCommunityMessage(on: req)
        }
    }
    
    /// Deletes a parameterized `CommunityMessage`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        let communityMessage = try req.parameter(Resource.self).await(on: req)
        try req.user().checkOwnership(for: communityMessage, on: req)
        
        return communityMessage.delete(on: req).transform(to: .ok)
    }
    
    /// Upvotes a parameterized `CommunityMessage`.
    func upvote(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameter(Resource.self).flatMap(to: HTTPStatus.self) { message in
            return try message.donate(.upvote, on: req)
        }
    }
    
    /// Downvotes a parameterized `CommunityMessage`.
    func downvote(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameter(Resource.self).flatMap(to: HTTPStatus.self) { message in
            return try message.donate(.downvote, on: req)
        }
    }

}
