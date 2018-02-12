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

/// Controls token-based authentication.
final class LoginController {
    
    /// Saves a new `Token` to the database.
    func login(_ req: Request) throws -> Future<Token.PublicToken> {
        let loginRequest = try LoginRequest.validate(req)
    
        return try User.query(on: req).group(.or) { builder in
            builder.filter(\User.email == loginRequest.user)
            builder.filter(\User.username == loginRequest.user)
        }.first().flatMap(to: Token.PublicToken.self) { existingUser in
            guard let user = existingUser else {
                // user not found
                throw Abort(.badRequest)
            }
            
            let hasher = try req.make(BCryptHasher.self)
            
            guard try hasher.verify(message: loginRequest.password, matches: user.password) else {
                // invalid password
                throw Abort(.badRequest)
            }
            
            return try Token(token: UUID().uuidString, userID: user.requireID()).create(on: req).map(to: Token.PublicToken.self) { token in
                return token.publicToken()
            }
        }
    }
    
    /// Revokes a supplied `Token`.
    func logout(_ req: Request) throws -> Future<HTTPStatus> {
        guard let requestedToken = req.http.headers.bearerAuthorization?.token else {
            // missing token
            throw Abort(.unauthorized)
        }
        
        return Token.query(on: req).filter(\Token.token == requestedToken).delete().transform(to: .ok)
    }
    
}

