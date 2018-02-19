//
//  UpvotedBy.swift
//  App
//
//  Created by Phillip Rust on 19.02.18.
//

import Foundation
import Vapor
import FluentSQLite

final class UpvotedBy: Content {
    var id: Int?
    var messageID: TrafficMessage.ID
    var userID: User.ID
    
    init(messageID: TrafficMessage.ID, userID: User.ID) {
        self.messageID = messageID
        self.userID = userID
    }
}

extension UpvotedBy: SQLiteModel, Migration {
    static var idKey: WritableKeyPath<UpvotedBy, Int?> {
        return \UpvotedBy.id
    }
}
