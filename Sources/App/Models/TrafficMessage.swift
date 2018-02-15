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
    var type: String
    var time: Date
    var location: String
    var direction: Double
    var note: String?
    var validators: Int = 0
    var upvotes: Int = 1
    
    init(senderID: Int, type: String, time: Date, location: String, direction: Double, note: String?) {
        self.senderID = senderID
        self.type = type
        self.time = time
        self.location = location
        self.direction = direction
        self.note = note
    }
    
    convenience init(senderID: Int, trafficRequest: TrafficMessageRequest) {
        self.init(senderID: senderID, type: trafficRequest.type, time: trafficRequest.time, location: trafficRequest.location, direction: trafficRequest.direction, note: trafficRequest.note)
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
