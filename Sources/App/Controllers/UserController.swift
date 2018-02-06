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
        let user = try req.content.decode(User.self).await(on: req)
        
        return User.query(on: req).filter(\User.email == user.email).first().flatMap(to: User.self) { existingUser in
            guard existingUser == nil else {
                throw Abort(.badRequest)
            }
            
            user.password = try req.make(BCryptHasher.self).make(user.password)
            return user.create(on: req)
        }
    }
    
    /// Deletes a parameterized `User`.
    // TODO: - check if token owns user
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        _ = try LoginController.validateToken(on:req).await(on: req)
        let user = try req.parameter(User.self).await(on: req)
        return user.delete(on: req).transform(to: .ok)
    }
    
    /// Returns a parameterized `User`.
    func get(_ req: Request) throws -> Future<User> {
        _ = try LoginController.validateToken(on:req).await(on: req)
        return try req.parameter(User.self)
    }
    
}
