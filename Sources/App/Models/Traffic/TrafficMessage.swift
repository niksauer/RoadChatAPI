//
//  TrafficMessage.swift
//  App
//
//  Created by Niklas Sauer on 13.02.18.
//

import Foundation
import Vapor
import FluentSQLite
import RoadChatKit

extension TrafficMessage: SQLiteModel, Migration {
    public static var idKey: WritableKeyPath<TrafficMessage, Int?> {
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
    public static func make(for parameter: String, using container: Container) throws -> Future<TrafficMessage> {
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
    
    func publicTrafficMessage(on req: Request) throws -> PublicTrafficMessage {
        return try PublicTrafficMessage(trafficMessage: self, upvotes: self.getKarmaLevel(on: req), validations: self.getValidationLevel(on: req))
    }
}

extension TrafficMessage.PublicTrafficMessage: Content {}
