//
//  Participation.swift
//  App
//
//  Created by Niklas Sauer on 18.02.18.
//

import Foundation
import Vapor
import FluentSQLite

enum ApprovalStatus: String {
    case requested
    case accepted
    case denied
}

final class Participation: Content {
    var id: Int?
    var userID: User.ID
    var conversationID: Conversation.ID
    var approvalStatus: String = ApprovalStatus.requested.rawValue
    var joining: Date = Date()
    
    init(userID: User.ID, conversationID: Conversation.ID) {
        self.userID = userID
        self.conversationID = conversationID
    }
}

extension Participation {
    func publicParticipant() -> PublicParticipant {
        return PublicParticipant(participant: self)
    }
    
    struct PublicParticipant: Content {
        let userID: User.ID
        let approvalStatus: String
        let joining: Date
        
        init(participant: Participation) {
            self.userID = participant.userID
            self.approvalStatus = participant.approvalStatus
            self.joining = participant.joining
        }
    }
}

extension Participation: SQLiteModel, Migration {
    static var idKey: WritableKeyPath<Participation, Int?> {
        return \Participation.id
    }
}

extension Participation: ModifiablePivot {
    typealias Left = User
    typealias Right = Conversation
    
    static var leftIDKey: WritableKeyPath<Participation, Int> {
        return \Participation.userID
    }
    
    static var rightIDKey: WritableKeyPath<Participation, Int> {
        return \Participation.conversationID
    }
    
    convenience init(_ left: Left, _ right: Right) throws {
        try self.init(userID: left.requireID(), conversationID: right.requireID())
    }
}

extension Request {
    /// Checks participation in a `Conversaton` according to the supplied `Token`.
    func checkParticipation(in conversation: Conversation) throws {
        guard try conversation.participations.isAttached(try self.user(), on: self).await(on: self) else {
            // user does not participate in conversation
            throw Abort(.unauthorized)
        }
    }
    
    /// Returns a `Participation` in a `Conversaton` according to the supplied `Token`.
    func getParticipation(in conversation: Conversation) throws -> Future<Participation> {
        return Participation.query(on: self).filter(try \Participation.userID == self.user().requireID()).filter(try \Participation.conversationID == conversation.requireID()).first().map(to: Participation.self) { participation in
            guard let participation = participation else {
                // user does not participate in conversation
                throw Abort(.unauthorized)
            }
            return participation
        }
    }
}
