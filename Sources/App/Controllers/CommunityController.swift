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
    
    /// Saves a new 'TrafficMessage' to the database.
    func create(_ req: Request) throws -> Future<CommunityMessage> {
        let user = try req.user()
        let communityMessageRequest = try CommunityMessageRequest.extract(from: req)
        
        return CommunityMessage(senderID: try user.requireID(), communityRequest: communityMessageRequest).create(on: req)
    }
    
    /// Returns a parameterized 'TrafficMessage'
    func get(_ req: Request) throws -> Future<CommunityMessage> {
        return try req.parameter(CommunityMessage.self)
    }
    
    /// Deletes a parameterized 'TrafficMessage'.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        let communityMessage = try req.parameter(CommunityMessage.self).await(on: req)
        try req.checkOwnership(for: communityMessage)
        
        return communityMessage.delete(on: req).transform(to: .ok)
    }
    
}
