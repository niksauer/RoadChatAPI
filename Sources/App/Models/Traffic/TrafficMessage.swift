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
    var type: String
    var time: Date
    var location: String
    var direction: Double
    var note: String?
//    var validators: Int = 0
    
    init(senderID: User.ID, type: String, time: Date, location: String, direction: Double, note: String?) {
        self.senderID = senderID
        self.type = type
        self.time = time
        self.location = location
        self.direction = direction
        self.note = note
    }
    
    convenience init(senderID: User.ID, trafficRequest: TrafficMessageRequest) {
        self.init(senderID: senderID, type: trafficRequest.type, time: trafficRequest.time, location: trafficRequest.location, direction: trafficRequest.direction, note: trafficRequest.note)
    }
}

extension TrafficMessage {
    func publicTrafficMessage(upvotes: Int) throws -> PublicTrafficMessage {
        return try PublicTrafficMessage(trafficMessage: self, upvotes: upvotes)
    }
    
    struct PublicTrafficMessage: Content {
        let id: Int
        let senderID: User.ID
        let type: String
        let time: Date
        let location: String
        let direction: Double
        let note: String?
//        let validators: Int
        let upvotes: Int
        
        init(trafficMessage: TrafficMessage, upvotes: Int) throws {
            self.id = try trafficMessage.requireID()
            self.senderID = trafficMessage.senderID
            self.type = trafficMessage.type
            self.time = trafficMessage.time
            self.location = trafficMessage.location
            self.direction = trafficMessage.direction
            self.note = trafficMessage.note
            self.upvotes = upvotes
        }
    }
}

extension TrafficMessage: SQLiteModel, Migration {
    static var idKey: WritableKeyPath<TrafficMessage, Int?> {
        return \TrafficMessage.id
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
