//
//  UserController.swift
//  App
//
//  Created by Niklas Sauer on 05.02.18.
//

import Foundation
import Vapor
import Fluent
import Crypto

/// Controls basic CRUD operations on `User`s.
final class UserController {
    
    /// Saves a decoded new `User` to the database.
    func create(_ req: Request) throws -> Future<User.PublicUser> {
        let registerRequest = try req.content.decode(RegisterRequest.self).await(on: req)
        
        return User.query(on: req).filter(\User.email == registerRequest.email).first().flatMap(to: User.PublicUser.self) { existingUser in
            guard existingUser == nil else {
                // duplicate email
                throw Abort(.badRequest)
            }
            
            let hasher = try req.make(BCryptHasher.self)
            let hashedPassword = try hasher.make(registerRequest.password)
            
            let newUser = User(email: registerRequest.email, username: registerRequest.username, password: hashedPassword)
            
            return newUser.create(on: req).map(to: User.PublicUser.self) { user in
                return try user.publicUser()
            }
        }
    }
    
    /// Deletes a parameterized `User`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        let requestedUser = try req.parameter(User.self).await(on: req)
        let authenticatedUser = try req.user()
        
        guard try requestedUser.requireID() == authenticatedUser.requireID() else {
            // attemp to delete unowned resource
            throw Abort(.forbidden)
        }
        
        return requestedUser.delete(on: req).transform(to: .ok)
    }
    
    /// Returns a parameterized `User`.
    func get(_ req: Request) throws -> Future<User.PublicUser> {
        return try req.parameter(User.self).map(to: User.PublicUser.self) { user in
            return try user.publicUser()
        }
    }
    
}
