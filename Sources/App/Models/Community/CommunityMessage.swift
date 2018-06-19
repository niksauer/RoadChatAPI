//
//  CommunityMessage.swift
//  App
//
//  Created by Niklas Sauer on 06.02.18.
//

import Foundation
import Vapor
import FluentMySQL
import RoadChatKit

extension CommunityMessage: MySQLModel, Migration {
    public static var idKey: WritableKeyPath<CommunityMessage, Int?> {
        return \CommunityMessage.id
    }
    
    public static var entity: String {
        return "CommunityMessage"
    }
}

extension CommunityMessage: Ownable {
    var owner: Parent<CommunityMessage, User> {
        return parent(\CommunityMessage.senderID)
    }
}

extension CommunityMessage: Parameter {
    public static func make(for parameter: String, using container: Container) throws -> Future<CommunityMessage> {
        guard let id = Int(parameter) else {
            // id must be integer
            throw Abort(.badRequest)
        }
        
        return container.newConnection(to: .mysql).flatMap(to: CommunityMessage.self) { database in
            return CommunityMessage.find(id, on: database).map(to: CommunityMessage.self) { existingMessage in
                guard let message = existingMessage else {
                    // message not found
                    throw Abort(.notFound)
                }
                
                return message
            }
        }
    }
}

extension CommunityMessage: Karmable {
    var donations: Siblings<CommunityMessage, User, CommunityMessageKarmaDonation> {
        return siblings()
    }
}

extension CommunityMessage {
    func publicCommunityMessage(on req: Request) throws -> Future<PublicCommunityMessage> {
        let user = try req.user()
        
        return try self.getKarmaLevel(on: req).flatMap(to: PublicCommunityMessage.self) { karmaLevel in
            return try self.getLocation(on: req).flatMap(to: PublicCommunityMessage.self) { location in
                guard let location = location else {
                    throw Abort(.internalServerError)
                }
                
                return try user.getDonation(for: self, on: req).map(to: PublicCommunityMessage.self) { donation in
                    guard let donation = donation, let karma = KarmaType(rawValue: donation.karma) else {
                        return try self.publicCommunityMessage(upvotes: karmaLevel, karma: .neutral, location: location)
                    }
                    
                    return try self.publicCommunityMessage(upvotes: karmaLevel, karma: karma, location: location)
                }
            }
        }
    }
    
    func getLocation(on req: Request) throws -> Future<Location?> {
        return Location.find(locationID, on: req)
    }
}

extension CommunityMessage.PublicCommunityMessage: Content {}

