//
//  CommunityMessage.swift
//  App
//
//  Created by Niklas Sauer on 06.02.18.
//

import Foundation
import Vapor
import FluentSQLite

final class CommunityMessage: SQLiteModel, Migration, Content, Parameter {
    
    static let idKey = \CommunityMessage.id
    
    var id: UUID?
    var senderID: Int
    var time: Date
    var location: String
    var message: String
    var upvotes: Int
    
    init(id: UUID?, senderID: Int, time: Date, location: String, message: String) {
        self.id = id
        self.senderID = senderID
        self.time = time
        self.location = location
        self.message = message
        self.upvotes = 1
    }
    
}
