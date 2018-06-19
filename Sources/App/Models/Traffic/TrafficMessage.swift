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
        return "TrafficMessage"
    }
    
    var validations: Siblings<TrafficMessage, User, TrafficMessageValidation> {
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
        
        return container.newConnection(to: .mysql).flatMap(to: TrafficMessage.self) { database in
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
        return TrafficMessageValidation.query(on: req).filter(try \TrafficMessageValidation.messageID == self.requireID()).count()
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
        let user = try req.user()
        
        return try self.getLocation(on: req).flatMap(to: PublicTrafficMessage.self) { location in
            return try self.getKarmaLevel(on: req).flatMap(to: PublicTrafficMessage.self) { karmaLevel in
                return try self.getValidationLevel(on: req).flatMap(to: PublicTrafficMessage.self) { validationLevel in
                    return try user.getDonation(for: self, on: req).map(to: PublicTrafficMessage.self) { donation in
                        guard let donation = donation, let karma = KarmaType(rawValue: donation.karma) else {
                            return try self.publicTrafficMessage(validations: validationLevel, upvotes: karmaLevel, karma: .neutral, location: location)
                        }
                        
                        return try self.publicTrafficMessage(validations: validationLevel, upvotes: karmaLevel, karma: karma, location: location)
                    }
                }
            }
        }
    }
}

extension TrafficMessage.PublicTrafficMessage: Content {}
