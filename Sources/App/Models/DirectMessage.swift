//
//  DirectMessage.swift
//  App
//
//  Created by Niklas Sauer on 17.02.18.
//

import Foundation
import Vapor
import FluentSQLite

final class DirectMessage: Content {
    var id: Int?
    var senderID: User.ID
    var conversationID: Conversation.ID
    var time: Date
    var message: String
    
    init(senderID: User.ID, conversationID: Conversation.ID, time: Date, message: String) {
        self.senderID = senderID
        self.conversationID = conversationID
        self.time = time
        self.message = message
    }
}

extension DirectMessage: SQLiteModel, Migration {
    static var idKey: WritableKeyPath<DirectMessage, Int?> {
        return \DirectMessage.id
    }
    
    var conversation: Parent<DirectMessage, Conversation> {
        return parent(\DirectMessage.conversationID)
    }
}

extension DirectMessage: Ownable {
    var owner: Parent<DirectMessage, User> {
        return parent(\DirectMessage.senderID)
    }
}
