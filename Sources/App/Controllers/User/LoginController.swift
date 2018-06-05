//
//  LoginController.swift
//  App
//
//  Created by Niklas Sauer on 06.02.18.
//

import Foundation
import Vapor
import Fluent
import Crypto
import RoadChatKit

/// Controls token-based authentication.
final class LoginController {
    
    typealias Resource = BearerToken
    typealias Result = BearerToken.PublicBearerToken
    
    /// Saves a new `Token` to the database.
    func login(_ req: Request) throws -> Future<Result> {
        return try LoginRequest.extract(from: req).flatMap(to: Result.self) { loginRequest in
            return try User.query(on: req).group(.or) { builder in
                try builder.filter(\User.email == loginRequest.user)
                try builder.filter(\User.username == loginRequest.user)
            }.first().flatMap(to: Result.self) { existingUser in
                guard let user = existingUser else {
                    // user not found
                    throw Abort(.badRequest)
                }
                
                let hasher = try req.make(BCryptDigest.self)
    
                guard try hasher.verify(loginRequest.password, created: user.password) else {
                    // invalid password
                    throw Abort(.badRequest)
                }
                
                return try BearerToken(userID: user.requireID(), token: UUID().uuidString).create(on: req).map(to: Result.self) { token in
                    return token.publicToken()
                }
            }
        }
    }
    
    /// Revokes a supplied `Token`.
    func logout(_ req: Request) throws -> Future<HTTPStatus> {
        guard let requestedToken = req.http.headers.bearerAuthorization?.token else {
            // missing token
            throw Abort(.unauthorized)
        }
        
        return try BearerToken.query(on: req).filter(\BearerToken.token == requestedToken).delete().transform(to: .ok)
    }
    
}

