//
//  Participation.swift
//  App
//
//  Created by Niklas Sauer on 18.02.18.
//

import Foundation
import Vapor
import FluentMySQL
import RoadChatKit

extension Participation: MySQLModel, Migration {
    public static var idKey: WritableKeyPath<Participation, Int?> {
        return \Participation.id
    }
    
    public static var entity: String {
        return "conversationParticipation"
    }
}

extension Participation: ModifiablePivot {
    public typealias Left = User
    public typealias Right = Conversation
    
    public static var leftIDKey: WritableKeyPath<Participation, Int> {
        return \Participation.userID
    }
    
    public static var rightIDKey: WritableKeyPath<Participation, Int> {
        return \Participation.conversationID
    }
    
    public convenience init(_ left: Left, _ right: Right) throws {
        try self.init(userID: left.requireID(), conversationID: right.requireID())
    }
}

extension Participation.PublicParticipant: Content {}

extension User {
    /// Checks participation of the `User` in a `Conversaton`.
    func checkParticipation(in conversation: Conversation, on req: Request) throws {
        _ = conversation.participations.isAttached(self, on: req).map(to: Void.self) { isParticipating in
            guard isParticipating else {
                // user does not participate in conversation
                throw Abort(.unauthorized)
            }
        }
    }
    
    /// Returns a `Participation` of the `User` in a `Conversaton`.
    func getParticipation(in conversation: Conversation, on req: Request) throws -> Future<Participation> {
        return Participation.query(on: req).filter(try \Participation.userID == self.requireID()).filter(try \Participation.conversationID == conversation.requireID()).first().map(to: Participation.self) { participation in
            guard let participation = participation else {
                // user does not participate in conversation
                throw Abort(.unauthorized)
            }
            return participation
        }
    }
}
