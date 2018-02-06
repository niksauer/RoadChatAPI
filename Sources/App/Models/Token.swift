//
//  Token.swift
//  App
//
//  Created by Niklas Sauer on 05.02.18.
//

import Foundation
import Vapor
import FluentSQLite

final class Token: SQLiteModel, Migration, Content {
    
    static let idKey = \Token.token
    
    var token: UUID?
    var userID: Int
    var expiry: Date
    var lastLogin: Date
    
    init(token: UUID?, userID: Int, expiry: Date) {
        self.token = token
        self.userID = userID
        self.expiry = expiry
        self.lastLogin = Date()
    }
    
}
