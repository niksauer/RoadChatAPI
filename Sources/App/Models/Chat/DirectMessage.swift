//
//  DirectMessage.swift
//  App
//
//  Created by Niklas Sauer on 17.02.18.
//

import Foundation
import Vapor
import FluentSQLite
import RoadChatKit

extension DirectMessage: SQLiteModel, Migration {
    public static var idKey: WritableKeyPath<DirectMessage, Int?> {
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

extension DirectMessage.PublicDirectMessage: Content {}
