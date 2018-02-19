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
    func index(_ req: Request) throws -> Future<[TrafficMessage.PublicTrafficMessage]> {
        return TrafficMessage.query(on: req).all().map(to: [TrafficMessage.PublicTrafficMessage].self) { messages in
            return try messages.map({ try $0.publicTrafficMessage(upvotes: try $0.getKarmaLevel(on: req).await(on: req)) })
        }
    }
    
    /// Saves a new `TrafficMessage` to the database.
    func create(_ req: Request) throws -> Future<TrafficMessage.PublicTrafficMessage> {
        let trafficMessageRequest = try TrafficMessageRequest.extract(from: req)
        let creator = try req.user()
        
        return TrafficMessage(senderID: try creator.requireID(), trafficRequest: trafficMessageRequest).create(on: req).flatMap(to: TrafficMessage.PublicTrafficMessage.self) { message in
            return message.interactions.attach(creator, on: req).map(to: TrafficMessage.PublicTrafficMessage.self) { interaction in
                interaction.karma = KarmaType.upvote.rawValue
                _ = interaction.save(on: req)
                return try message.publicTrafficMessage(upvotes: message.getKarmaLevel(on: req).await(on: req))
            }
        }
    }
    
    /// Returns a parameterized `TrafficMessage`.
    func get(_ req: Request) throws -> Future<TrafficMessage.PublicTrafficMessage> {
        return try req.parameter(TrafficMessage.self).map(to: TrafficMessage.PublicTrafficMessage.self) { message in
            let upvotes = try message.getKarmaLevel(on: req).await(on: req)
            return try message.publicTrafficMessage(upvotes: upvotes)
        }
    }
    
    /// Deletes a parameterized `TrafficMessage`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        let trafficMessage = try req.parameter(TrafficMessage.self).await(on: req)
        try req.checkOwnership(for: trafficMessage)
        
        return trafficMessage.delete(on: req).transform(to: .ok)
    }
    
    /// Upvotes a parameterized `TrafficMessage`.
    func upvote(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameter(TrafficMessage.self).flatMap(to: HTTPStatus.self) { message in
            return try message.donate(.upvote, on: req)
        }
    }

    /// Downvotes a parameterized `TrafficMessage`.
    func downvote(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameter(TrafficMessage.self).flatMap(to: HTTPStatus.self) { message in
            return try message.donate(.downvote, on: req)
        }
    }
}

