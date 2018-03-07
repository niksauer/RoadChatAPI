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
        return "directMessage"
    }
    
    var conversation: Parent<DirectMessage, Conversation> {
        return parent(\DirectMessage.conversationID)
    }
    
    public static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return MySQLDatabase.create(self, on: connection) { builder in
            try builder.field(for: \DirectMessage.id)
            try builder.field(for: \DirectMessage.senderID)
            try builder.field(for: \DirectMessage.conversationID)
            try builder.field(for: \DirectMessage.time)
            builder.field(type: .text(), for: \DirectMessage.message)
        }
    }
}

extension DirectMessage: Ownable {
    var owner: Parent<DirectMessage, User> {
        return parent(\DirectMessage.senderID)
    }
}

extension DirectMessage.PublicDirectMessage: Content {}
