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
    var email: String
    var username: String
    var password: String
    var registry: Date = Date()
    
    init(email: String, username: String, password: String) {
        self.email = email
        self.username = username
        self.password = password
    }

    convenience init(registerRequest: RegisterRequest) {
        self.init(email: registerRequest.email, username: registerRequest.username, password: registerRequest.password)
    }
}

extension User {
    func publicUser() throws -> PublicUser {
        return try PublicUser(user: self)
    }
    
    struct PublicUser: Content {
        let id: Int
        let email: String
        let username: String
        let registry: Date
        
        init(user: User) throws {
            self.id = try user.requireID()
            self.email = user.email
            self.username = user.username
            self.registry = user.registry
        }
    }
}

extension User: SQLiteModel, Migration {
    static var idKey: WritableKeyPath<User, Int?> {
        return \User.id
    }
    
    var settings: Children<User, Settings> {
        return children(\Settings.userID)
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
    
    func getProfile(on req: Request) throws -> Future<Profile?> {
        return try profile.query(on: req).first()
    }
    
    func getCars(on req: Request) throws -> Future<[Car]> {
        return try cars.query(on: req).all()
    }
    
    func getCommunityMessages(on req: Request) throws -> Future<[CommunityMessage]> {
        return try communityMessages.query(on: req).all()
    }
    
    func getTrafficMessages(on req: Request) throws -> Future<[TrafficMessage]> {
        return try trafficMessages.query(on: req).all()
    }
}

