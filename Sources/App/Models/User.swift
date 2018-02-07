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

final class User: Content, Parameter {
    var id: Int?
    var email: String
    var username: String
    var password: String
    var registry: Date
    
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

extension User: SQLiteModel, Migration {
    static var idKey: ReferenceWritableKeyPath<User, Int?> {
        return \User.id
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

extension User: TokenAuthenticatable {
    typealias TokenType = Token
}

extension Request {
    func user() throws -> User {
        return try requireAuthenticated(User.self)
    }
}
