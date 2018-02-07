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
    func create(_ req: Request) throws -> Future<User> {
        var registerRequest = try req.content.decode(RegisterRequest.self).await(on: req)
        
        return User.query(on: req).filter(\User.email == registerRequest.email).first().flatMap(to: User.self) { existingUser in
            guard existingUser == nil else {
                throw Abort(.badRequest)
            }
            
            let hasher = try req.make(BCryptHasher.self)
            registerRequest.password = try hasher.make(registerRequest.password)
            
            return User(registerRequest: registerRequest).create(on: req)
        }
    }
    
    /// Deletes a parameterized `User`.
    // TODO: check if token owns user to be deleted
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        let user = try req.parameter(User.self).await(on: req)
        return user.delete(on: req).transform(to: .ok)
    }
    
    /// Returns a parameterized `User`.
    func get(_ req: Request) throws -> Future<User> {
        return try req.parameter(User.self)
    }
    
}
