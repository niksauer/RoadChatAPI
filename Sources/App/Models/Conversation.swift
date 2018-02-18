//
//  Conversation.swift
//  App
//
//  Created by Niklas Sauer on 17.02.18.
//

import Foundation
import Vapor
import FluentSQLite

final class Conversation: Content {
    var id: Int?
    var creatorID: User.ID
    var title: String
    var creation: Date = Date()
    
    init(creatorID: User.ID, title: String) {
        self.creatorID = creatorID
        self.title = title
    }
}

extension Conversation: SQLiteModel, Migration {
    static var idKey: WritableKeyPath<Conversation, Int?> {
        return \Conversation.id
    }
    
    var directMessages: Children<Conversation, DirectMessage> {
        return children(\DirectMessage.conversationID)
    }
}

extension Conversation: Ownable {
    var owner: Parent<Conversation, User> {
        return parent(\Conversation.creatorID)
    }
}
