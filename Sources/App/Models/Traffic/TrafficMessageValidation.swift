//
//  TrafficMessageValidation.swift
//  App
//
//  Created by Phillip Rust on 21.02.18.
//

import Foundation
import Vapor
import FluentMySQL
import RoadChatKit

final class TrafficMessageValidation: Codable {
    var id: Int?
    var userID: User.ID
    var messageID: TrafficMessage.ID
    
    init(userID: User.ID, messageID: TrafficMessage.ID) {
        self.userID = userID
        self.messageID = messageID
    }
}

extension TrafficMessageValidation: MySQLModel, Migration {
    static var idKey: WritableKeyPath<TrafficMessageValidation, Int?> {
        return \TrafficMessageValidation.id
    }
    
    public static var entity: String {
        return "TrafficMessageValidation"
    }
}

extension TrafficMessageValidation: ModifiablePivot {
    typealias Left = User
    typealias Right = TrafficMessage
    
    static var leftIDKey: WritableKeyPath<TrafficMessageValidation, Int> {
        return \TrafficMessageValidation.userID
    }
    
    static var rightIDKey: WritableKeyPath<TrafficMessageValidation, Int> {
        return \TrafficMessageValidation.messageID
    }
    
    convenience init(_ left: Left, _ right: Right) throws {
        try self.init(userID: left.requireID(), messageID: right.requireID())
    }
}
