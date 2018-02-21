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
    
    /// Returns all `CommunityMessage`s.
    func index(_ req: Request) throws -> Future<[CommunityMessage]> {
        return CommunityMessage.query(on: req).all()
    }
    
    /// Saves a new 'CommunityMessage' to the database.
    func create(_ req: Request) throws -> Future<CommunityMessage> {
        let user = try req.user()
        let communityMessageRequest = try CommunityMessageRequest.extract(from: req)
        
        return CommunityMessage(senderID: try user.requireID(), communityRequest: communityMessageRequest).create(on: req)
    }
    
    /// Returns a parameterized 'CommunityMessage'
    func get(_ req: Request) throws -> Future<CommunityMessage> {
        return try req.parameter(CommunityMessage.self)
    }
    
    /// Deletes a parameterized 'CommunityMessage'.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        let communityMessage = try req.parameter(CommunityMessage.self).await(on: req)
        try req.user().checkOwnership(for: communityMessage, on: req)
        
        return communityMessage.delete(on: req).transform(to: .ok)
    }
    
    /// Upvotes a parameterized `CommunityMessage`.
    func upvote(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameter(CommunityMessage.self).flatMap(to: HTTPStatus.self) { message in
            return try message.donate(.upvote, on: req)
        }
    }
    
    /// Downvotes a parameterized `CommunityMessage`.
    func downvote(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameter(CommunityMessage.self).flatMap(to: HTTPStatus.self) { message in
            return try message.donate(.downvote, on: req)
        }
    
}
}
