//
//  DirectMessage.swift
//  App
//
//  Created by Niklas Sauer on 17.02.18.
//

import Foundation
import Vapor
import FluentMySQL
import RoadChatKit

extension DirectMessage: MySQLModel, Migration {
    public static var idKey: WritableKeyPath<DirectMessage, Int?> {
        return \DirectMessage.id
    }
    
    public static var entity: String {
        return "DirectMessage"
    }
    
    public static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return MySQLDatabase.create(self, on: connection) { builder in
            builder.field(for: \DirectMessage.id)
            builder.field(for: \DirectMessage.senderID)
            builder.field(for: \DirectMessage.conversationID)
            builder.field(for: \DirectMessage.time)
            builder.field(for: \DirectMessage.message)
        }
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
