//
//  Ownable.swift
//  App
//
//  Created by Niklas Sauer on 16.02.18.
//

import Foundation
import Vapor
import FluentMySQL

protocol Owner: MySQLModel {
    var id: Int? { get }
}

protocol Ownable: MySQLModel {
    associatedtype OwnerResource: Owner
    var owner: Parent<Self, OwnerResource> { get }
}

extension Owner {
    /// Checks resource ownership for an `Ownable`.
    func checkOwnership<T: Ownable>(for resource: T, on req: Request) throws {
        guard let owner = try resource.owner.query(on: req).first().await(on: req) else {
            // no owner associated to resource
            throw Abort(.internalServerError)
        }
        
        guard owner.id == self.id else {
            // unowned resource
            throw Abort(.forbidden)
        }
    }
}

extension Request {
    func checkOptionalOwnership<T: Ownable>(for resource: T) throws {
        guard let authenticatedUser = try self.optionalUser() else {
            // no token supplied
            throw Abort(.unauthorized)
        }
        
        try authenticatedUser.checkOwnership(for: resource, on: self)
    }
}
