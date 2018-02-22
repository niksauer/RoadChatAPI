//
//  TrafficController.swift
//  App
//
//  Created by Niklas Sauer on 14.02.18.
//

import Foundation
import Vapor
import Fluent
//import CoreLocation
import GeoSwift

/// Controls basic CRUD operations on `TrafficMessage`s.
final class TrafficController {
    
    typealias Resource = TrafficMessage
    typealias Result = TrafficMessage.PublicTrafficMessage
    
    /// Returns all `TrafficMessage`s.
    func index(_ req: Request) throws -> Future<[Result]> {
        return TrafficMessage.query(on: req).all().map(to: [Result].self) { messages in
            return try messages.map({ try $0.publicTrafficMessage(on: req) })
        }
    }

    /// Saves a new `TrafficMessage` to the database.
    func create(_ req: Request) throws -> Future<Result> {
        let trafficMessageRequest = try TrafficMessageRequest.extract(from: req)
        let creator = try req.user()
        
        let requestLocation = Location(userID: try creator.requireID(), trafficMessageRequest: trafficMessageRequest)
        let requestGeoLocation = try GeoCoordinate2D(latitude: requestLocation.latitude, longitude: requestLocation.longitude)
        
        guard let compareDate = Calendar.current.date(byAdding: .hour, value: -1, to: trafficMessageRequest.time) else {
            throw Abort(.internalServerError)
        }
        
        let recentMessages = try TrafficMessage.query(on: req).filter(\TrafficMessage.type == trafficMessageRequest.type).filter(\TrafficMessage.time > compareDate).sort(\TrafficMessage.time, .ascending).all().await(on: req)
    
        for message in recentMessages {
            guard let location = try Location.query(on: req).filter(\Location.id == message.locationID).filter(\Location.course >= requestLocation.course - 90).filter(\Location.course <= requestLocation.course + 90).first().await(on: req) else {
                continue
            }
            
            let geoLocation = try GeoCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
            if geoLocation.distance(from: requestGeoLocation) < 500 {
                _ = message.validations.attach(creator, on: req)
                return Future(try message.publicTrafficMessage(on: req))
            }
        }
        
        return requestLocation.create(on: req).flatMap(to: TrafficMessage.PublicTrafficMessage.self) { location in
            return TrafficMessage(senderID: try creator.requireID(), locationID: try location.requireID(), trafficRequest: trafficMessageRequest).create(on: req).flatMap(to: TrafficMessage.PublicTrafficMessage.self) { message in
                return message.interactions.attach(creator, on: req).map(to: TrafficMessage.PublicTrafficMessage.self) { interaction in
                    interaction.karma = KarmaType.upvote.rawValue
                    _ = interaction.save(on: req)
                    return try message.publicTrafficMessage(on: req)
                }
            }
        }
    }
    
    /// Returns a parameterized `TrafficMessage`.
    func get(_ req: Request) throws -> Future<Result> {
        return try req.parameter(Resource.self).map(to: Result.self) { message in
            return try message.publicTrafficMessage(on: req)
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

