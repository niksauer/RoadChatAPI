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
    // TODO: allow login via email/username
    // TODO: do not store token in database
    func login(_ req: Request) throws -> Future<Token> {
        let loginRequest = try req.content.decode(LoginRequest.self).await(on: req)
        
        return User.query(on: req).filter(\User.email == loginRequest.email).first().flatMap(to: Token.self) { user in
            guard let user = user else {
                throw Abort(.badRequest)
            }

            let hasher = try req.make(BCryptHasher.self)
            
            guard try hasher.verify(message: loginRequest.password, matches: user.password) else {
                throw Abort(.badRequest)
            }
        
            let expiry = Calendar.current.date(byAdding: .day, value: 1, to: Date())!

            return try Token(token: UUID().uuidString, userID: user.requireID(), expiry: expiry).create(on: req)
        }
    }
    
    func logout(_ req: Request) throws -> Future<HTTPStatus> {
        let requestedToken = req.http.headers.bearerAuthorization!.token
        return Token.query(on: req).filter(\Token.token == requestedToken).delete().transform(to: .ok)
    }
}

