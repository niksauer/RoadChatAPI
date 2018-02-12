//
//  CommunityMessage.swift
//  App
//
//  Created by Niklas Sauer on 06.02.18.
//

import Foundation
import Vapor
import FluentSQLite

final class CommunityMessage:  Content {
    var id: Int?
    var senderID: Int
    var time: Date
    var location: String
    var message: String
    var upvotes: Int = 1
    
    init(senderID: Int, time: Date, location: String, message: String) {
        self.senderID = senderID
        self.time = time
        self.location = location
        self.message = message
    }
    
    convenience init(communityRequest: CommunityRequest) {
        self.init(senderID: communityRequest.senderID, time: communityRequest.time, location: communityRequest.location, message: communityRequest.message)
    }
}

extension CommunityMessage: SQLiteModel, Migration {
    static var idKey: ReferenceWritableKeyPath<CommunityMessage, Int?> {
        return \CommunityMessage.id
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
