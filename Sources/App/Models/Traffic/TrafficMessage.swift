//
//  TrafficMessage.swift
//  App
//
//  Created by Niklas Sauer on 13.02.18.
//

import Foundation
import Vapor
import FluentSQLite

final class TrafficMessage: Content {
    var id: Int?
    var senderID: User.ID
    var locationID: Location.ID
    var type: String
    var time: Date
    var message: String?
    
    init(senderID: User.ID, locationID: Location.ID, type: String, time: Date, message: String?) {
        self.senderID = senderID
        self.locationID = locationID
        self.type = type
        self.time = time
        self.message = message
    }
    
    convenience init(senderID: User.ID, locationID: Location.ID, trafficRequest: TrafficMessageRequest) {
        self.init(senderID: senderID, locationID: locationID, type: trafficRequest.type, time: trafficRequest.time, message: trafficRequest.message)
    }
}

extension TrafficMessage {
    func publicTrafficMessage(on req: Request) throws -> PublicTrafficMessage {
        return try PublicTrafficMessage(trafficMessage: self, upvotes: self.getKarmaLevel(on: req), validations: self.getValidationLevel(on: req))
    }
    
    struct PublicTrafficMessage: Content {
        var id: Int
        var senderID: User.ID
        var locationID: Location.ID
        var type: String
        var time: Date
        var message: String?
        var validations: Int
        var upvotes: Int
        
        init(trafficMessage: TrafficMessage, upvotes: Int, validations: Int) throws {
            self.id = try trafficMessage.requireID()
            self.senderID = trafficMessage.senderID
            self.locationID = trafficMessage.locationID
            self.type = trafficMessage.type
            self.time = trafficMessage.time
            self.message = trafficMessage.message
            self.upvotes = upvotes
            self.validations = validations
        }
    }
}

extension TrafficMessage: SQLiteModel, Migration {
    static var idKey: WritableKeyPath<TrafficMessage, Int?> {
        return \TrafficMessage.id
    }
    
    var validations: Siblings<TrafficMessage, User, Validation> {
        return siblings()
    }
}

extension TrafficMessage: Ownable {
    var owner: Parent<TrafficMessage, User> {
        return parent(\TrafficMessage.senderID)
    }
}

extension TrafficMessage: Parameter {
    static func make(for parameter: String, using container: Container) throws -> Future<TrafficMessage> {
        guard let id = Int(parameter) else {
            // id must be integer
            throw Abort(.badRequest)
        }
        
        return container.requestConnection(to: .sqlite).flatMap(to: TrafficMessage.self) { database in
            return TrafficMessage.find(id, on: database).map(to: TrafficMessage.self) { existingTrafficMessage in
                guard let trafficMessage = existingTrafficMessage else {
                    // traffic message not found
                    throw Abort(.notFound)
                }
                
                return trafficMessage
            }
        }
    }
}

extension TrafficMessage: Karmable {    
    var donations: Siblings<TrafficMessage, User, TrafficMessageKarmaDonation> {
        return siblings()
    }
}

extension TrafficMessage {
    func getValidationLevel(on req: Request) throws -> Int {
        return try Validation.query(on: req).filter(try \Validation.messageID == self.requireID()).count().await(on: req)
    }
    
    func getLocation(on req: Request) throws -> Future<Location> {
        return Location.query(on: req).filter(\Location.id == self.locationID).first().map(to: Location.self) { location in
            guard let location = location else {
                throw Abort(.internalServerError)
            }
            
            return location
        }
    }
}
