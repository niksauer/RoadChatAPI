//
//  Ownable.swift
//  App
//
//  Created by Niklas Sauer on 16.02.18.
//

import Foundation
import Vapor
import FluentSQLite

protocol Owner: SQLiteModel {
    var id: Int? { get }
}

protocol Ownable: SQLiteModel {
    associatedtype OwnerResource: Owner
    var owner: Parent<Self, OwnerResource> { get }
}

extension Request {
    /// Checks resource ownership for an `Ownable` according to the supplied `Token`.
    func checkOwnership<T: Ownable>(for resource: T) throws {
        guard let owner = try resource.owner.query(on: self).first().await(on: self) else {
            // no owner associated to resource
            throw Abort(.internalServerError)
        }
        
        let authenticatedUser = try self.user()
        
        guard try owner.id == authenticatedUser.requireID() else {
            // unowned resource
            throw Abort(.forbidden)
        }
    }
}
