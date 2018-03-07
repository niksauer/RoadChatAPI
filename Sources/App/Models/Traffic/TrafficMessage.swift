//
//  TrafficMessage.swift
//  App
//
//  Created by Niklas Sauer on 13.02.18.
//

import Foundation
import Vapor
import FluentMySQL
import RoadChatKit

extension TrafficMessage: MySQLModel, Migration {
    public static var idKey: WritableKeyPath<TrafficMessage, Int?> {
        return \TrafficMessage.id
    }
    
    public static var entity: String {
        return "trafficMessage"
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
        
        return container.requestConnection(to: .mysql).flatMap(to: TrafficMessage.self) { database in
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
    func getValidationLevel(on req: Request) throws -> Future<Int> {
        return Validation.query(on: req).filter(try \Validation.messageID == self.requireID()).count()
    }
    
    func getLocation(on req: Request) throws -> Future<Location> {
        return Location.query(on: req).filter(\Location.id == self.locationID).first().map(to: Location.self) { location in
            guard let location = location else {
                throw Abort(.internalServerError)
            }
            
            return location
        }
    }
    
    func publicTrafficMessage(on req: Request) throws -> Future<PublicTrafficMessage> {
        return try self.getKarmaLevel(on: req).flatMap(to: PublicTrafficMessage.self) { karmaLevel in
            return try self.getValidationLevel(on: req).map(to: PublicTrafficMessage.self) { validationLevel in
                return try PublicTrafficMessage(trafficMessage: self, upvotes: karmaLevel, validations: validationLevel)
            }
        }
    }
}

extension TrafficMessage.PublicTrafficMessage: Content {}
