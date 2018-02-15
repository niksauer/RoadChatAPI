//
//  TrafficController.swift
//  App
//
//  Created by Niklas Sauer on 14.02.18.
//

import Foundation
import Vapor
import Fluent

/// Controls basic CRUD operations on `TrafficMessage`s.
final class TrafficController {
    
    /// Returns all `TrafficMessage`s.
    func index(_ req: Request) throws -> Future<[TrafficMessage]> {
        return TrafficMessage.query(on: req).all()
    }
    
    /// Saves a new 'TrafficMessage' to the database.
    func create(_ req: Request) throws -> Future<TrafficMessage> {
        let user = try req.user()
        let trafficMessageRequest = try TrafficMessageRequest.extract(from: req)
       
        return TrafficMessage(senderID: try user.requireID(), trafficRequest: trafficMessageRequest).create(on: req)
    }
    
}
