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
    var registry: Date
    
    var settings: Children<User, Settings> {
        return children(\Settings.userID)
    }
    
    init(email: String, username: String, password: String) {
        self.email = email
        self.username = username
        self.password = password
        self.registry = Date()
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
    static var idKey: ReferenceWritableKeyPath<User, Int?> {
        return \User.id
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
}

