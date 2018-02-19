//
//  DownvotedBy.swift
//  App
//
//  Created by Phillip Rust on 19.02.18.
//

import Foundation
import Vapor
import FluentSQLite

final class DownvotedBy: Content {
    var id: Int?
    var messageID: TrafficMessage.ID
    var userID: User.ID
    
    init(messageID: TrafficMessage.ID, userID: User.ID) {
        self.messageID = messageID
        self.userID = userID
    }
}

extension DownvotedBy: SQLiteModel, Migration {
    static var idKey: WritableKeyPath<DownvotedBy, Int?> {
        return \DownvotedBy.id
    }
}
