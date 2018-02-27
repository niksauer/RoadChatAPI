//
//  User.swift
//  App
//
//  Created by Niklas Sauer on 05.02.18.
//

import Foundation
import Vapor
import FluentSQLite
import Authentication

final class User: Content {
    var id: Int?
    var locationID: Location.ID?
    var email: String
    var username: String
    var password: String
    var registry: Date = Date()
    
    init(email: String, username: String, password: String) {
        self.email = email
        self.username = username
        self.password = password
    }

    convenience init(registerRequest request: RegisterRequest) {
        self.init(email: request.email, username: request.username, password: request.password)
    }
}

extension User {
    func publicUser(isOwner: Bool) throws -> PublicUser {
        return try PublicUser(user: self, isOwner: isOwner)
    }
    
    func publicUser(location: Location) throws -> PublicUser {
        return try PublicUser(user: self, location: location)
    }
    
    struct PublicUser: Content {
        let id: Int
        var email: String?
        let username: String
        let registry: Date
        
        var timestamp: Date?
        var latitude: Double?
        var longitude: Double?
        var altitude: Double?
        var horizontalAccuracy: Double?
        var verticalAccuracy: Double?
        var course: Double?
        var speed: Double?
        
        init(user: User, isOwner: Bool) throws {
            self.id = try user.requireID()
            
            if isOwner {
                self.email = user.email
            }
            
            self.username = user.username
            self.registry = user.registry
        }
        
        init(user: User, location: Location) throws {
            self.id = try user.requireID()
            self.username = user.username
            self.registry = user.registry
            
            self.timestamp = location.timestamp
            self.latitude = location.latitude
            self.longitude = location.longitude
            self.altitude = location.altitude
            self.horizontalAccuracy = location.horizontalAccuracy
            self.verticalAccuracy = location.verticalAccuracy
            self.course = location.course
            self.speed = location.speed
        }
    }
}

extension User: SQLiteModel, Migration, Owner {
    static var idKey: WritableKeyPath<User, Int?> {
        return \User.id
    }
    
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
    static func make(for parameter: String, using container: Container) throws -> Future<User> {
        guard let id = Int(parameter) else {
            // id must be integer
            throw Abort(.badRequest)
        }
        
        return container.requestConnection(to: .sqlite).flatMap(to: User.self) { database in
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
    typealias TokenType = Token
}

extension Request {
    func user() throws -> User {
        return try requireAuthenticated(User.self)
    }
    
    func optionalUser() throws -> User? {
        if let token = self.http.headers.bearerAuthorization?.token {
            guard let storedToken = try Token.query(on: self).filter(\Token.token == token).first().await(on: self) else {
                return nil
            }
            
            return try storedToken.authUser.get(on: self).await(on: self) as User
        } else {
            return nil
        }
    }
}

extension User {
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
}

