//
//  User.swift
//  App
//
//  Created by Niklas Sauer on 05.02.18.
//

import Foundation
import Vapor
import FluentSQLite

final class User: SQLiteModel, Migration, Content, Parameter {
    
    static let idKey = \User.id

    var id: Int?
    var email: String
    var username: String
    var password: String
//    var registry: Date

    init(id: Int?, email: String, username: String, password: String) {
        self.id = id
        self.email = email
        self.username = username
        self.password = password
//        self.registry = Date()
    }
    
//    static func make(for parameter: String, using container: Container) throws -> Future<User> {
//        guard let id = Int(parameter) else {
//            throw Abort(.badRequest)
//        }
//
//        return User.find(id, on: <#T##DatabaseConnectable#>)
//    }
    
}
