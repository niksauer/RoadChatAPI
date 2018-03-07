//
//  Validation.swift
//  App
//
//  Created by Phillip Rust on 21.02.18.
//

import Foundation
import Vapor
import FluentMySQL
import RoadChatKit

final class Validation: Codable {
    var id: Int?
    var userID: User.ID
    var messageID: TrafficMessage.ID
    
    init(userID: User.ID, messageID: TrafficMessage.ID) {
        self.userID = userID
        self.messageID = messageID
    }
}

extension Validation: MySQLModel, Migration {
    static var idKey: WritableKeyPath<Validation, Int?> {
        return \Validation.id
    }
    
    public static var entity: String {
        return "trafficValidation"
    }
}

extension Validation: ModifiablePivot {
    typealias Left = User
    typealias Right = TrafficMessage
    
    static var leftIDKey: WritableKeyPath<Validation, Int> {
        return \Validation.userID
    }
    
    static var rightIDKey: WritableKeyPath<Validation, Int> {
        return \Validation.messageID
    }
    
    convenience init(_ left: Left, _ right: Right) throws {
        try self.init(userID: left.requireID(), messageID: right.requireID())
    }
}
