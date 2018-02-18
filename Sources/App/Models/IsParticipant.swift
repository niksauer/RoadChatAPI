//
//  IsParticipant.swift
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

final class IsParticipant: Content {
    var id: Int?
    var userID: User.ID
    var conversationID: Conversation.ID
    var approvalStatus: String = ApprovalStatus.requested.rawValue
    
    init(userID: User.ID, conversationID: Conversation.ID) {
        self.userID = userID
        self.conversationID = conversationID
    }
    
    init(userID: User.ID, conversationID: Conversation.ID, approvalStatus: ApprovalStatus) {
        self.userID = userID
        self.conversationID = conversationID
        self.approvalStatus = approvalStatus.rawValue
    }
}

extension IsParticipant: SQLiteModel, Migration {
    static var idKey: WritableKeyPath<IsParticipant, Int?> {
        return \IsParticipant.id
    }
}

extension IsParticipant: Pivot {
    typealias Left = User
    typealias Right = Conversation
    
    static var leftIDKey: ReferenceWritableKeyPath<IsParticipant, Int> {
        return \IsParticipant.userID
    }
    
    static var rightIDKey: ReferenceWritableKeyPath<IsParticipant, Int> {
        return \IsParticipant.conversationID
    }
}
