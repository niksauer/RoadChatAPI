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
    
    /// Saves a new `Token` to the database.
    func login(_ req: Request) throws -> Future<BearerToken.PublicBearerToken> {
        return try LoginRequest.extract(from: req).flatMap(to: BearerToken.PublicBearerToken.self) { loginRequest in
            return User.query(on: req).group(.or) { builder in
                builder.filter(\User.email == loginRequest.user)
                builder.filter(\User.username == loginRequest.user)
            }.first().flatMap(to: BearerToken.PublicBearerToken.self) { existingUser in
                guard let user = existingUser else {
                    // user not found
                    throw Abort(.badRequest)
                }
                
                let hasher = try req.make(BCryptHasher.self)
                
                guard try hasher.verify(message: loginRequest.password, matches: user.password) else {
                    // invalid password
                    throw Abort(.badRequest)
                }
                
                return try BearerToken(userID: user.requireID(), token: UUID().uuidString).create(on: req).map(to: BearerToken.PublicBearerToken.self) { token in
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
        
        return BearerToken.query(on: req).filter(\BearerToken.token == requestedToken).delete().transform(to: .ok)
    }
    
}

