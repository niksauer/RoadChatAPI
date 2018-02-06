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
        // delete any expired tokens
        _ = Token.query(on: req).filter(\Token.expiry < Date()).delete()

        let email: String = try req.content.get(at: "email").await(on: req)
        let password: String = try req.content.get(at: "password").await(on: req)

        return User.query(on: req).filter(\User.email == email).first().flatMap(to: Token.self) { user in
            guard let user = user else {
                throw Abort(.badRequest)
            }

            guard try req.make(BCryptHasher.self).verify(message: password, matches: user.password) else {
                throw Abort(.unauthorized)
            }
            
            let expiry = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
            let token = Token(token: nil, userID: user.id!, expiry: expiry)

            return token.create(on: req)
        }
    }
    
    func logout(_ req: Request) throws -> Future<HTTPStatus> {
        let token = try LoginController.validateToken(on: req).await(on: req)
        return token.delete(on: req).transform(to: .ok)
    }
    
    static func validateToken(on req: Request) throws -> Future<Token> {
        let token: UUID = try req.content.get(at: "token").await(on: req)
        
        return Token.find(token, on: req).flatMap(to: Token.self) { token in
            guard let token = token else {
                throw Abort(.unauthorized)
            }
            
            if token.expiry < Date() {
                // delete token if expired
                return token.delete(on: req).flatMap(to: Token.self) {
                    throw Abort(.unauthorized)
                }
            } else {
                return Future(token)
            }
        }
    }
    
}
