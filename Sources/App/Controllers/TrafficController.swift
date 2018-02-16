//
//  TrafficController.swift
//  App
//
//  Created by Niklas Sauer on 14.02.18.
//

import Foundation
import Vapor
import Fluent

/// Controls basic CRUD operations on `TrafficMessage`s.
final class TrafficController {
    
    /// Returns all `TrafficMessage`s.
    func index(_ req: Request) throws -> Future<[TrafficMessage]> {
        return TrafficMessage.query(on: req).all()
    }
    
    /// Saves a new 'TrafficMessage' to the database.
    func create(_ req: Request) throws -> Future<TrafficMessage> {
        let user = try req.user()
        let trafficMessageRequest = try TrafficMessageRequest.extract(from: req)
       
        return TrafficMessage(senderID: try user.requireID(), trafficRequest: trafficMessageRequest).create(on: req)
    }
    
    /// Returns a parameterized 'TrafficMessage'
    func get(_ req: Request) throws -> Future<TrafficMessage> {
        return try req.parameter(TrafficMessage.self)
    }
    
    /// Deletes a parameterized 'TrafficMessage'.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        let trafficMessage = try checkOwnership(req)
        return trafficMessage.delete(on: req).transform(to: .ok)
    }
    
    /// Checks resource ownership for a parameterized 'TrafficMessage' according to the supplied token.
    private func checkOwnership(_ req: Request) throws -> TrafficMessage {
        let requestedTrafficMessage = try req.parameter(TrafficMessage.self).await(on: req)
        let authenticatedUser = try req.user()
        
        guard try requestedTrafficMessage.senderID == authenticatedUser.requireID() else {
            // unowned resource
            throw Abort(.forbidden)
        }
        
        return requestedTrafficMessage
    }
}

