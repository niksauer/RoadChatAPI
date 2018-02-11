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
        let registerRequest: RegisterRequest
        
        do {
            registerRequest = try req.content.decode(RegisterRequest.self).await(on: req)
        } catch {
            // missing parameter
            throw APIFail.invalidRegisterRequest
        }
        
        return User.query(on: req).filter(\User.email == registerRequest.email).first().flatMap(to: User.PublicUser.self) { existingUser in
            guard existingUser == nil else {
                // email already registered
                throw APIFail.emailTaken
            }
            
            return User.query(on: req).filter(\User.username == registerRequest.username).first().flatMap(to: User.PublicUser.self) { existingUser in
                guard existingUser == nil else {
                    // username taken
                    throw APIFail.usernameTaken
                }
                
                let hasher = try req.make(BCryptHasher.self)
                let hashedPassword = try hasher.make(registerRequest.password)
                
                let newUser = User(email: registerRequest.email, username: registerRequest.username, password: hashedPassword)
                
                return newUser.create(on: req).map(to: User.PublicUser.self) { user in
                    return try user.publicUser()
                }
            }
        }
    }
    
    /// Returns a parameterized `User`.
    func get(_ req: Request) throws -> Future<User.PublicUser> {
        return try req.parameter(User.self).map(to: User.PublicUser.self) { user in
            return try user.publicUser()
        }
    }
    
    /// Updates a parameterized `User`.
    func update(_ req: Request) throws -> Future<HTTPStatus> {
        let user = try checkOwnership(req)
        let updatedUser: RegisterRequest
            
        do {
            updatedUser = try req.content.decode(RegisterRequest.self).await(on: req)
        } catch {
            // missing parameter
            throw APIFail.invalidUpdateRequest
        }
        
        let hasher = try req.make(BCryptHasher.self)
        let hashedPassword = try hasher.make(updatedUser.password)
        
        user.email = updatedUser.email
        user.username = updatedUser.username
        user.password = hashedPassword
        
        return user.update(on: req).transform(to: .ok)
    }
    
    /// Deletes a parameterized `User`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        let user = try checkOwnership(req)
        
        // delete requested user and revoke all of his tokens
        return try user.authTokens.query(on: req).delete().flatMap(to: HTTPStatus.self) {
            return user.delete(on: req).transform(to: .ok)
        }
    }
    
    /// Checks resource ownership for a parameterized `User` according to the supplied token.
    func checkOwnership(_ req: Request) throws -> User {
        let requestedUser = try req.parameter(User.self).await(on: req)
        let authenticatedUser = try req.user()
        
        guard try requestedUser.requireID() == authenticatedUser.requireID() else {
            // unowned resource
            throw Abort(.forbidden)
        }
        
        return authenticatedUser
    }
    
}
