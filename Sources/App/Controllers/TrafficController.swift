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
    
    /// Returns a parameterized 'TrafficMessage'
    func get(_ req: Request) throws -> Future<TrafficMessage> {
        return try req.parameter(TrafficMessage.self)
    }
    
    /// Deletes a parameterized 'TrafficMessage'.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        let trafficMessage = try req.parameter(TrafficMessage.self).await(on: req)
        try req.checkOwnership(for: trafficMessage)
        
        return trafficMessage.delete(on: req).transform(to: .ok)
    }
    
    /// Upvotes a parameterized 'TrafficMessage'.
    func upvote(_ req: Request) throws -> Future<HTTPStatus> {
        let trafficMessage = try req.parameter(TrafficMessage.self).await(on: req)
        let user = try req.user()
    
        let upvoteStatus = try checkUpvoteStatus(req: req, trafficMessage: trafficMessage, user: user).await(on: req)
        
        if (upvoteStatus != nil) {
            trafficMessage.upvotes -= 1
            _ = upvoteStatus!.delete(on: req)
        }
        else {
            let downvoteStatus = try checkDownvoteStatus(req: req, trafficMessage: trafficMessage, user: user).await(on: req)
            if (downvoteStatus != nil) {
                trafficMessage.upvotes += 2
                _ = downvoteStatus!.delete(on: req)
                _ = UpvotedBy(messageID: trafficMessage.id!, userID: user.id!).create(on: req)
                
            }
            else {
                trafficMessage.upvotes += 1
                _ = UpvotedBy(messageID: trafficMessage.id!, userID: user.id!).create(on: req)
            }
        }
        return trafficMessage.update(on: req).transform(to: .ok)
    }

    
    /// Downvotes a parameterized 'TrafficMessage'.
    func downvote(_ req: Request) throws -> Future<HTTPStatus> {
        let trafficMessage = try req.parameter(TrafficMessage.self).await(on: req)
        let user = try req.user()
        
        let downvoteStatus = try checkDownvoteStatus(req: req, trafficMessage: trafficMessage, user: user).await(on: req)
        if (downvoteStatus != nil) {
            trafficMessage.upvotes += 1
            _ = downvoteStatus!.delete(on: req)
        }
        else {
            let upvoteStatus = try checkUpvoteStatus(req: req, trafficMessage: trafficMessage, user: user).await(on: req)
            if (upvoteStatus != nil) {
                trafficMessage.upvotes -= 2
                _ = upvoteStatus!.delete(on: req)
                _ = DownvotedBy(messageID: trafficMessage.id!, userID: user.id!).create(on: req)
                
            }
            else {
                trafficMessage.upvotes -= 1
                _ = DownvotedBy(messageID: trafficMessage.id!, userID: user.id!).create(on: req)
            }
        }
        return trafficMessage.update(on: req).transform(to: .ok)
    }
    
    func checkUpvoteStatus(req: Request, trafficMessage: TrafficMessage, user: User)  -> Future<UpvotedBy?> {
        return UpvotedBy.query(on: req).group(.and) { builder in
            builder.filter(\UpvotedBy.messageID == trafficMessage.id!)
            builder.filter(\UpvotedBy.userID == user.id!)
            }.first()
    }
    
    func checkDownvoteStatus(req: Request, trafficMessage: TrafficMessage, user: User) -> Future<DownvotedBy?> {
        return DownvotedBy.query(on: req).group(.and) { builder in
            builder.filter(\DownvotedBy.messageID == trafficMessage.id!)
            builder.filter(\DownvotedBy.userID == user.id!)
            }.first()
    }
}

