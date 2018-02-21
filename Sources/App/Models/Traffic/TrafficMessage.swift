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
    var note: String?
//    var validators: Int = 0
    
    init(senderID: User.ID, locationID: Location.ID, type: String, time: Date, note: String?) {
        self.senderID = senderID
        self.locationID = locationID
        self.type = type
        self.time = time
        self.note = note
    }
    
    convenience init(senderID: User.ID, locationID: Location.ID, trafficRequest: TrafficMessageRequest) {
        self.init(senderID: senderID, locationID: locationID, type: trafficRequest.type, time: trafficRequest.time, note: trafficRequest.note)
    }
}

extension TrafficMessage {
    func publicTrafficMessage(upvotes: Int) throws -> PublicTrafficMessage {
        return try PublicTrafficMessage(trafficMessage: self, upvotes: upvotes)
    }
    
    struct PublicTrafficMessage: Content {
        var id: Int
        var senderID: User.ID
        var locationID: Location.ID
        var type: String
        var time: Date
        var note: String?
        //    var validators: Int = 0
        var upvotes: Int
        
        init(trafficMessage: TrafficMessage, upvotes: Int) throws {
            self.id = try trafficMessage.requireID()
            self.senderID = trafficMessage.senderID
            self.locationID = trafficMessage.locationID
            self.type = trafficMessage.type
            self.time = trafficMessage.time
            self.note = trafficMessage.note
            self.upvotes = upvotes
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
    var interactions: Siblings<TrafficMessage, User, TrafficKarmaDonation> {
        return siblings()
    }
    
    func donate(_ karma: KarmaType, on req: Request) throws -> Future<HTTPStatus> {
        return try req.getInteraction(with: self).flatMap(to: HTTPStatus.self) { interaction in
            guard let interaction = interaction else {
                return self.interactions.attach(try req.user(), on: req).flatMap(to: HTTPStatus.self) { newInteraction in
                    newInteraction.setKarmaType(karma)
                    return newInteraction.save(on: req).transform(to: .ok)
                }
            }
            
            if karma == .upvote {
                switch try interaction.getKarmaType() {
                case .upvote:
                    interaction.karma = KarmaType.neutral.rawValue
                case .neutral:
                    interaction.karma = KarmaType.upvote.rawValue
                case .downvote:
                    interaction.karma = KarmaType.upvote.rawValue
                }
            } else {
                switch try interaction.getKarmaType() {
                case .upvote:
                    interaction.karma = KarmaType.downvote.rawValue
                case .neutral:
                    interaction.karma = KarmaType.downvote.rawValue
                case .downvote:
                    interaction.karma = KarmaType.neutral.rawValue
                }
            }
            
            return interaction.save(on: req).transform(to: HTTPStatus.ok)
        }
    }
}
