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
    var messageID: Int
    var userID: User.ID
    
    init(messageID: Int, userID: User.ID) {
        self.messageID = messageID
        self.userID = userID
    }
}
