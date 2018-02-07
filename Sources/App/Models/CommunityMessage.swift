//
//  CommunityMessage.swift
//  App
//
//  Created by Niklas Sauer on 06.02.18.
//

import Foundation
import Vapor
import FluentSQLite

final class CommunityMessage:  Content, Parameter {
    var id: Int?
    var senderID: Int
    var time: Date
    var location: String
    var message: String
    var upvotes: Int
    
    init(senderID: Int, time: Date, location: String, message: String) {
        self.senderID = senderID
        self.time = time
        self.location = location
        self.message = message
        self.upvotes = 1
    }
}

extension CommunityMessage: SQLiteModel, Migration {
    static var idKey: ReferenceWritableKeyPath<CommunityMessage, Int?> {
        return \CommunityMessage.id
    }
}
