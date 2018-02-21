//
//  Validation.swift
//  App
//
//  Created by Phillip Rust on 21.02.18.
//

import Foundation
import Vapor
import FluentSQLite

final class Validation: Content {
    var id: Int?
    var userID: User.ID
    var messageID: TrafficMessage.ID
    
    init(userID: User.ID, messageID: TrafficMessage.ID) {
        self.userID = userID
        self.messageID = messageID

    }
}

extension Validation: SQLiteModel, Migration {
    static var idKey: WritableKeyPath<Validation, Int?> {
        return \Validation.id
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

extension Request {
    /// Checks validation of a `TrafficMessage` according to the supplied `Token`.
    func checkValidation(of trafficMessage: TrafficMessage) throws {
        guard try trafficMessage.validations.isAttached(try self.user(), on: self).await(on: self) else {
            // user does not validate traffic message
            throw Abort(.unauthorized)
        }
    }
    
    /// Returns a `Validation` of `TrafficMessage` according to the supplied `Token`.
    func getValidation(of trafficMessage: TrafficMessage) throws -> Future<Validation> {
        return Validation.query(on: self).filter(try \Validation.userID == self.user().requireID()).filter(try \Validation.messageID == trafficMessage.requireID()).first().map(to: Validation.self) { validation in
            guard let validation = validation else {
                // user does not validate traffic message
                throw Abort(.unauthorized)
            }
            return validation
        }
    }
}
