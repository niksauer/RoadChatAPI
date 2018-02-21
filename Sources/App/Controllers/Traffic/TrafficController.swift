//
//  TrafficController.swift
//  App
//
//  Created by Niklas Sauer on 14.02.18.
//

import Foundation
import Vapor
import Fluent
import CoreLocation

/// Controls basic CRUD operations on `TrafficMessage`s.
final class TrafficController {
    
    /// Returns all `TrafficMessage`s.
    func index(_ req: Request) throws -> Future<[TrafficMessage.PublicTrafficMessage]> {
        return TrafficMessage.query(on: req).all().map(to: [TrafficMessage.PublicTrafficMessage].self) { messages in
            var result = [TrafficMessage.PublicTrafficMessage]()
            for message in messages {
                let upvotes = try message.getKarmaLevel(on: req).await(on: req)
                let validations = try message.getValidationLevel(on: req)
                result.append(try message.publicTrafficMessage(upvotes: upvotes, validations: validations))
            }
            return result
        }
    }
    
    /// Saves a new `TrafficMessage` to the database.
    func create(_ req: Request) throws -> Future<TrafficMessage.PublicTrafficMessage> {
        let trafficMessageRequest = try TrafficMessageRequest.extract(from: req)
        let creator = try req.user()
        
        let requestLocation = Location(userID: try creator.requireID(), trafficMessageRequest: trafficMessageRequest)
        let requestCLLocation = CLLocation(location: requestLocation)
        
        guard let compareDate = Calendar.current.date(byAdding: .hour, value: -1, to: trafficMessageRequest.time) else {
            throw Abort(.internalServerError)
        }
        
        let recentMessages = try TrafficMessage.query(on: req).filter(\TrafficMessage.type == trafficMessageRequest.type).filter(\TrafficMessage.time > compareDate).sort(\TrafficMessage.time, .ascending).all().await(on: req)
        print(recentMessages)
        for message in recentMessages {
            guard let location = try Location.query(on: req).filter(\Location.id == message.locationID).first().await(on: req) else {
                continue
            }
            
            let clLocation = CLLocation(location: location)
            
            if clLocation.distance(from: requestCLLocation) < 500 {
                _ = message.validations.attach(creator, on: req)
                return Future(try message.publicTrafficMessage(upvotes: message.getKarmaLevel(on: req).await(on: req), validations: message.getValidationLevel(on: req)))
            }
        }
        
        return requestLocation.create(on: req).flatMap(to: TrafficMessage.PublicTrafficMessage.self) { location in
            return TrafficMessage(senderID: try creator.requireID(), locationID: try location.requireID(), trafficRequest: trafficMessageRequest).create(on: req).flatMap(to: TrafficMessage.PublicTrafficMessage.self) { message in
                return message.interactions.attach(creator, on: req).map(to: TrafficMessage.PublicTrafficMessage.self) { interaction in
                    interaction.karma = KarmaType.upvote.rawValue
                    _ = interaction.save(on: req)
                    return try message.publicTrafficMessage(upvotes: message.getKarmaLevel(on: req).await(on: req), validations: message.getValidationLevel(on: req))
                }
            }
        }
    }
    
    /// Returns a parameterized `TrafficMessage`.
    func get(_ req: Request) throws -> Future<TrafficMessage.PublicTrafficMessage> {
        return try req.parameter(TrafficMessage.self).map(to: TrafficMessage.PublicTrafficMessage.self) { message in
            let upvotes = try message.getKarmaLevel(on: req).await(on: req)
            return try message.publicTrafficMessage(upvotes: upvotes, validations: message.getValidationLevel(on: req))
        }
    }
    
    /// Deletes a parameterized `TrafficMessage`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        let trafficMessage = try req.parameter(TrafficMessage.self).await(on: req)
        try req.user().checkOwnership(for: trafficMessage, on: req)
        
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

