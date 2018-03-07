//
//  Token.swift
//  App
//
//  Created by Niklas Sauer on 05.02.18.
//

import Foundation
import Vapor
import FluentMySQL
import Authentication
import RoadChatKit

extension BearerToken: MySQLModel, Migration {
    public static var idKey: WritableKeyPath<BearerToken, Int?> {
        return \BearerToken.id
    }
}

extension BearerToken: BearerAuthenticatable, Authentication.Token {
    public typealias UserType = User
    
    public static var userIDKey: WritableKeyPath<BearerToken, Int> {
        return \BearerToken.userID
    }
    
    public static var tokenKey: WritableKeyPath<BearerToken, String> {
        return \BearerToken.token
    }
}

extension BearerToken.PublicBearerToken: Content {}
