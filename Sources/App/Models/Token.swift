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
    var token: String
    var userID: User.ID
    
    init(token: String, userID: User.ID) {
        self.token = token
        self.userID = userID
    }
}

extension Token: SQLiteModel, Migration {
    static var idKey: ReferenceWritableKeyPath<Token, Int?> {
        return \Token.id
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

extension Token: BearerAuthenticatable, Authentication.Token {
    typealias UserType = User
    
    static var userIDKey: ReferenceWritableKeyPath<Token, Int> {
        return \Token.userID
    }
    
    static var tokenKey: ReferenceWritableKeyPath<Token, String> {
        return \Token.token
    }
}

