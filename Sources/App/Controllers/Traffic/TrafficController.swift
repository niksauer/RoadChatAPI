//
//  TrafficController.swift
//  App
//
//  Created by Niklas Sauer on 14.02.18.
//

import Foundation
import Vapor
import Fluent
import GeoSwift
import RoadChatKit

/// Controls basic CRUD operations on `TrafficMessage`s.
final class TrafficController {
    
    typealias Resource = TrafficMessage
    typealias Result = TrafficMessage.PublicTrafficMessage
    
    /// Returns all `TrafficMessage`s.
    func index(_ req: Request) throws -> Future<[Result]> {
        return TrafficMessage.query(on: req).all().map(to: [Result].self) { messages in
            return try messages.map({ try $0.publicTrafficMessage(on: req).await(on: req) })
        }
    }

    /// Saves a new `TrafficMessage` to the database.
    func create(_ req: Request) throws -> Future<Result> {
        return try TrafficMessageRequest.extract(from: req).flatMap(to: Result.self) { trafficMessageRequest in
            let creator = try req.user()
            
            let requestLocation = Location(trafficMessageRequest: trafficMessageRequest)
            let requestGeoLocation = try GeoCoordinate2D(latitude: requestLocation.latitude, longitude: requestLocation.longitude)
            
            guard let compareDate = Calendar.current.date(byAdding: .hour, value: -1, to: trafficMessageRequest.time) else {
                throw Abort(.internalServerError)
            }
            
            return TrafficMessage.query(on: req).filter(\TrafficMessage.type == trafficMessageRequest.type).filter(\TrafficMessage.time > compareDate).sort(\TrafficMessage.time, .ascending).all().flatMap(to: Result.self) { recentMessages in
                for message in recentMessages {
                    let location = try message.getLocation(on: req).await(on: req)
                    let geoLocation = try GeoCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                    
                    if geoLocation.distance(from: requestGeoLocation) < 500 && self.validateCourse(course: location.course, requestCourse: requestLocation.course) == true {
                        _ = message.validations.attach(creator, on: req)
                        return try message.publicTrafficMessage(on: req)
                    }
                }
                
                return requestLocation.create(on: req).flatMap(to: Result.self) { location in
                    return TrafficMessage(senderID: try creator.requireID(), locationID: try location.requireID(), trafficRequest: trafficMessageRequest).create(on: req).flatMap(to: Result.self) { message in
                        return try creator.donate(.upvote, to: message, on: req).flatMap(to: Result.self) { _ in
                            return try message.publicTrafficMessage(on: req)
                        }
                    }
                }
            }
        }
    }
    
    /// Returns a parameterized `TrafficMessage`.
    func get(_ req: Request) throws -> Future<Result> {
        return try req.parameter(Resource.self).flatMap(to: Result.self) { message in
            return try message.publicTrafficMessage(on: req)
        }
    }
    
    /// Deletes a parameterized `TrafficMessage`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameter(Resource.self).flatMap(to: HTTPStatus.self) { trafficMessage in
            try req.user().checkOwnership(for: trafficMessage, on: req)
            return trafficMessage.delete(on: req).transform(to: .ok)
        }
    }
    
    /// Upvotes a parameterized `TrafficMessage`.
    func upvote(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameter(Resource.self).flatMap(to: HTTPStatus.self) { message in
            return try req.user().donate(.upvote, to: message, on: req)
        }
    }

    /// Downvotes a parameterized `TrafficMessage`.
    func downvote(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameter(Resource.self).flatMap(to: HTTPStatus.self) { message in
            return try req.user().donate(.downvote, to: message, on: req)
        }
    }
    
    /// Checks if the course of a `Location` in the database is within 90 degrees range of the `Location` from the request
    func validateCourse(course: Double, requestCourse: Double) -> Bool {
        let left: Double
        let right: Double
        
        if requestCourse < 90 {
            left = 360-abs(requestCourse - 90).truncatingRemainder(dividingBy: 360)
        } else {
            left = (requestCourse - 90).truncatingRemainder(dividingBy: 360)
        }
        right = (requestCourse + 90).truncatingRemainder(dividingBy: 360)
        
        if requestCourse >= 270 || requestCourse < 90 {
            
            if course >= 0 && course < 180 {
                return course <= left && course <= right
            } else {
                return course >= left
            }
            
        } else {
            return course >= left && course <= right
        }
    }
}
