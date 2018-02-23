//
//  DirectMessage.swift
//  App
//
//  Created by Niklas Sauer on 17.02.18.
//

import Foundation
import Vapor
import FluentMySQL

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
    
    init(senderID: User.ID, conversationID: Conversation.ID, messageRequest: DirectMessageRequest) {
        self.senderID = senderID
        self.conversationID = conversationID
        self.time = messageRequest.time
        self.message = messageRequest.message
    }
}

extension DirectMessage {
    func publicDirectMessage() throws -> PublicDirectMessage {
        return PublicDirectMessage(directMessage: self)
    }
    
    struct PublicDirectMessage: Content {
        let senderID: User.ID
        let time: Date
        let message: String
        
        init(directMessage: DirectMessage) {
            self.senderID = directMessage.senderID
            self.time = directMessage.time
            self.message = directMessage.message
        }
    }
}

extension DirectMessage: MySQLModel, Migration {
    static var idKey: WritableKeyPath<DirectMessage, Int?> {
        return \DirectMessage.id
    }
    
    static var entity: String {
        return "directMessage"
    }
    
    var conversation: Parent<DirectMessage, Conversation> {
        return parent(\DirectMessage.conversationID)
    }
    
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
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
