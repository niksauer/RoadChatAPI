//
//  CommunityMessage.swift
//  App
//
//  Created by Niklas Sauer on 06.02.18.
//

import Foundation
import Vapor
import FluentSQLite

final class CommunityMessage: Content {
    var id: Int?
    var senderID: User.ID
    var locationID: Location.ID
    var time: Date
    var message: String
    
    init(senderID: User.ID, locationID: Location.ID, time: Date, message: String) {
        self.senderID = senderID
        self.locationID = locationID
        self.time = time
        self.message = message
    }
    
    convenience init(senderID: User.ID, locationID: Location.ID, communityRequest: CommunityMessageRequest) {
        self.init(senderID: senderID, locationID: locationID, time: communityRequest.time, message: communityRequest.message)
    }
}

extension CommunityMessage {
    func publicCommunityMessage(on req: Request) throws -> PublicCommunityMessage {
        return try PublicCommunityMessage(communityMessage: self, upvotes: self.getKarmaLevel(on: req))
    }
    
    struct PublicCommunityMessage: Content {
        let id: Int
        let senderID: User.ID
        let locationID: Location.ID
        let time: Date
        let message: String
        let upvotes: Int
        
        init(communityMessage: CommunityMessage, upvotes: Int) throws {
            self.id = try communityMessage.requireID()
            self.senderID = communityMessage.senderID
            self.locationID = communityMessage.locationID
            self.time = communityMessage.time
            self.message = communityMessage.message
            self.upvotes = upvotes
        }
    }
}

extension CommunityMessage: SQLiteModel, Migration {
    static var idKey: WritableKeyPath<CommunityMessage, Int?> {
        return \CommunityMessage.id
    }
}

extension CommunityMessage: Ownable {
    var owner: Parent<CommunityMessage, User> {
        return parent(\CommunityMessage.senderID)
    }
}

extension CommunityMessage: Parameter {
    static func make(for parameter: String, using container: Container) throws -> Future<CommunityMessage> {
        guard let id = Int(parameter) else {
            // id must be integer
            throw Abort(.badRequest)
        }
        
        return container.requestConnection(to: .sqlite).flatMap(to: CommunityMessage.self) { database in
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

