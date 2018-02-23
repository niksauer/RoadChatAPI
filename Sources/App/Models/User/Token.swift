//
//  Token.swift
//  App
//
//  Created by Niklas Sauer on 05.02.18.
//

import Foundation
import Vapor
import FluentSQLite
import Authentication

final class Token: Content {
    var id: Int?
    var userID: User.ID
    var token: String
    
    init(userID: User.ID, token: String) {
        self.userID = userID
        self.token = token
    }
}

extension Token {
    func publicToken() -> PublicToken {
        return PublicToken(token: self.token)
    }
    
    struct PublicToken: Content {
        let token: String
    }
}

extension Token: SQLiteModel, Migration {
    static var idKey: WritableKeyPath<Token, Int?> {
        return \Token.id
    }
}

extension Token: BearerAuthenticatable, Authentication.Token {
    typealias UserType = User
    
    static var userIDKey: WritableKeyPath<Token, Int> {
        return \Token.userID
    }
    
    static var tokenKey: WritableKeyPath<Token, String> {
        return \Token.token
    }
}

