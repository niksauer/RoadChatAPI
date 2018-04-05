//
//  CommunityMessage.swift
//  App
//
//  Created by Niklas Sauer on 06.02.18.
//

import Foundation
import Vapor
import FluentSQLite
import RoadChatKit

extension CommunityMessage: SQLiteModel, Migration {
    public static var idKey: WritableKeyPath<CommunityMessage, Int?> {
        return \CommunityMessage.id
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
        
        return container.requestConnection(to: .sqlite).flatMap(to: CommunityMessage.self) { database in
            return try CommunityMessage.find(id, on: database).map(to: CommunityMessage.self) { existingMessage in
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
        return try self.getKarmaLevel(on: req).map(to: PublicCommunityMessage.self) { karmaLevel in
            return try PublicCommunityMessage(communityMessage: self, upvotes: karmaLevel)
        }
    }
}

extension CommunityMessage.PublicCommunityMessage: Content {}

