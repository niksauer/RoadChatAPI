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
    
    typealias Resource = TrafficMessage
    typealias Result = TrafficMessage.PublicTrafficMessage
    
    /// Returns all `TrafficMessage`s.
    func index(_ req: Request) throws -> Future<[TrafficMessage.PublicTrafficMessage]> {
        return TrafficMessage.query(on: req).all().map(to: [TrafficMessage.PublicTrafficMessage].self) { messages in
            return try messages.map({ try $0.publicTrafficMessage(upvotes: try $0.getKarmaLevel(on: req)) })
        }
    }
    
    /// Saves a new `TrafficMessage` to the database.
    func create(_ req: Request) throws -> Future<Result> {
        let trafficMessageRequest = try TrafficMessageRequest.extract(from: req)
        let creator = try req.user()
        
        return TrafficMessage(senderID: try creator.requireID(), trafficRequest: trafficMessageRequest).create(on: req).flatMap(to: Result.self) { message in
            return message.interactions.attach(creator, on: req).map(to: Result.self) { interaction in
                interaction.karma = KarmaType.upvote.rawValue
                _ = interaction.save(on: req)
                return try message.publicTrafficMessage(upvotes: 1)
            }
        }
    }
    
    /// Returns a parameterized `TrafficMessage`.
    func get(_ req: Request) throws -> Future<TrafficMessage.PublicTrafficMessage> {
        return try req.parameter(TrafficMessage.self).map(to: TrafficMessage.PublicTrafficMessage.self) { message in
            return try message.publicTrafficMessage(upvotes: message.getKarmaLevel(on: req))
        }
    }
    
    /// Deletes a parameterized `TrafficMessage`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        let trafficMessage = try req.parameter(Resource.self).await(on: req)
        try req.user().checkOwnership(for: trafficMessage, on: req)
        
        return trafficMessage.delete(on: req).transform(to: .ok)
    }
    
    /// Upvotes a parameterized `TrafficMessage`.
    func upvote(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameter(Resource.self).flatMap(to: HTTPStatus.self) { message in
            return try message.donate(.upvote, on: req)
        }
    }

    /// Downvotes a parameterized `TrafficMessage`.
    func downvote(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameter(Resource.self).flatMap(to: HTTPStatus.self) { message in
            return try message.donate(.downvote, on: req)
        }
    }
}

