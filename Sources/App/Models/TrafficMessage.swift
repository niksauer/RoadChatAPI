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
    var senderID: Int
    var time: Date
    var location: String
    var direction: String
    var note: String?
    var validators: [String]?
    var upvotes: Int = 1
    
    init(senderID: Int, time: Date, location: String, direction: String, note: String?) {
        self.senderID = senderID
        self.time = time
        self.location = location
        self.direction = direction
        self.note = note
    }
    
    convenience init(trafficRequest: TrafficMessageRequest) {
        self.init(senderID: trafficRequest.senderID, time: trafficRequest.time, location: trafficRequest.location, direction: trafficRequest.direction, note: trafficRequest.note)
    }
}

extension TrafficMessage: SQLiteModel, Migration {
    static var idKey: WritableKeyPath<TrafficMessage, Int?> {
        return \TrafficMessage.id
    }
    
    var sender: Parent<TrafficMessage, User> {
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
