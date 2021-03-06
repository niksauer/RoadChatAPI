//
//  User.swift
//  App
//
//  Created by Niklas Sauer on 05.02.18.
//

import Foundation
import Vapor
import FluentMySQL
import Authentication
import RoadChatKit

extension User: MySQLModel, Migration, Owner, KarmaDonator {
    public static var idKey: WritableKeyPath<User, Int?> {
        return \User.id
    }
    
    public static var entity: String {
        return "User"
    }

//    public static func prepare(on connection: MySQLConnection) -> Future<Void> {
//        return MySQLDatabase.create(self, on: connection) { builder in
//            try builder.field(for: \User.id)
//            try builder.field(for: \User.locationID)
//            try builder.field(for: \User.email)
//            try builder.field(for: \User.username)
////            try builder.field(type: .binary(length: 100), for: \User.password)
////            try builder.field(type: .blob(length: 100), for: \User.password)
//            try builder.field(for: \User.registry)
//        }
//    }
    
    var settings: Children<User, Settings> {
        return children(\Settings.userID)
    }
    
    var privacy: Children<User, Privacy> {
        return children(\Privacy.userID)
    }
    
    var profile: Children<User, Profile> {
        return children(\Profile.userID)
    }
    
    var cars: Children<User, Car> {
        return children(\Car.userID)
    }
    
    var trafficMessages: Children<User, TrafficMessage> {
        return children(\TrafficMessage.senderID)
    }
    
    var communityMessages: Children<User, CommunityMessage> {
        return children(\CommunityMessage.senderID)
    }
    
    var conversations: Siblings<User, Conversation, Participation> {
        return siblings()
    }
    
}

extension User: Ownable {
    var owner: Parent<User, User> {
        return parent(\User.id!)
    }
}

extension User: Parameter {
    public static func make(for parameter: String, using container: Container) throws -> Future<User> {
        guard let id = Int(parameter) else {
            // id must be integer
            throw Abort(.badRequest)
        }
        
        return container.newConnection(to: .mysql).flatMap(to: User.self) { database in
            return User.find(id, on: database).map(to: User.self) { existingUser in
                guard let user = existingUser else {
                    // user not found
                    throw Abort(.notFound)
                }
                
                return user
            }
        }
    }
}

extension User: TokenAuthenticatable {
    public typealias TokenType = BearerToken
}

extension User.PublicUser: Content {}

extension Request {
    func user() throws -> User {
        return try requireAuthenticated(User.self)
    }
    
    func optionalUser() throws -> Future<User?> {
        if let token = self.http.headers.bearerAuthorization?.token {
            return BearerToken.query(on: self).filter(\BearerToken.token == token).first().flatMap(to: User?.self) { storedToken in
                guard let storedToken = storedToken else {
                    return Future.map(on: self) { nil }
                }
                
                return storedToken.authUser.get(on: self).map(to: User?.self) { user in
                    return user
                }
            }
        } else {
            return Future.map(on: self) { nil }
        }
    }
}

extension User {
    func publicUser(on req: Request) throws -> Future<User.PublicUser> {
        return try self.getLocation(on: req).flatMap(to: User.PublicUser.self) { location in
            return try self.getPrivacy(on: req).flatMap(to: User.PublicUser.self) { privacy in
                do {
                    try req.checkOptionalOwnership(for: self)
                    return Future.map(on: req) { try self.publicUser(isOwner: true, privacy: privacy.publicPrivacy(), location: location) }
                } catch {
                    guard privacy.shareLocation else {
                        return Future.map(on: req) { try self.publicUser(isOwner: false, privacy: privacy.publicPrivacy(), location: nil) }
                    }
                    
                    return Future.map(on: req) { try self.publicUser(isOwner: false, privacy: privacy.publicPrivacy(), location: location)}
                }
            }
        }
    }
    
    func getSettings(on req: Request) throws -> Future<Settings> {
        return try settings.query(on: req).first().map(to: Settings.self) { settings in
            guard let settings = settings else {
                // no settings associated to user
                throw Abort(.internalServerError)
            }
            
            return settings
        }
    }
    
    func getPrivacy(on req: Request) throws -> Future<Privacy> {
        return try privacy.query(on: req).first().map(to: Privacy.self) { privacy in
            guard let privacy = privacy else {
                // no data sharing options associated to user
                throw Abort(.internalServerError)
            }
            
            return privacy
        }
    }
    
    func getProfile(on req: Request) throws -> Future<Profile?> {
        return try profile.query(on: req).first()
    }
    
    func getCars(on req: Request) throws -> Future<[Car]> {
        return try cars.query(on: req).all()
    }
    
    func getTrafficMessages(on req: Request) throws -> Future<[TrafficMessage]> {
        return try trafficMessages.query(on: req).all()
    }
    
    func getCommunityMessages(on req: Request) throws -> Future<[CommunityMessage]> {
        return try communityMessages.query(on: req).all()
    }
    
    func getConversations(on req: Request) throws -> Future<[Conversation]> {
        return try conversations.query(on: req).all()
    }
    
    func getLocation(on req: Request) throws -> Future<Location?> {
        return Location.query(on: req).filter(\Location.id == self.locationID).first()
    }
    
    func findConversation(recipientID: Int, on req: Request) throws -> Future<Conversation?> {
        return try self.getConversations(on: req).flatMap(to: Conversation?.self) { conversations in
            return try conversations.map { conversation in
                return try conversation.publicConversation(on: req)
            }.flatMap(to: Conversation?.self, on: req) { publicConversations in
                let oneOnOneConversations = publicConversations.filter { $0.participants.count == 2 }
                
                for conversation in oneOnOneConversations {
                    guard try conversation.participants.contains(where: { try $0.user.id == self.requireID() }), conversation.participants.contains(where: { $0.user.id == recipientID }) else {
                        continue
                    }
                    
                    return Conversation.query(on: req).filter(\Conversation.id == conversation.id).first()
                }
                
                return Future.map(on: req) { nil }
            }
        }
    }
    
    func setStatus(_ status: ApprovalType, conversation: Conversation, on req: Request) throws -> Future<HTTPStatus> {
        return try self.getParticipation(in: conversation, on: req).flatMap(to: HTTPStatus.self) { participation in
            participation.status = status.rawValue
            return participation.save(on: req).transform(to: .ok)
        }
    }
}

