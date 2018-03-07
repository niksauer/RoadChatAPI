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

extension Owner {
    /// Checks resource ownership for an `Ownable`.
    func checkOwnership<T: Ownable>(for resource: T, on req: Request) throws {
        _ = resource.owner.query(on: req).first().map(to: Void.self) { owner in
            guard let owner = owner else {
                // no owner associated to resource
                throw Abort(.internalServerError)
            }
            
            guard owner.id == self.id else {
                // unowned resource
                throw Abort(.forbidden)
            }
        }
    }
}

extension Request {
    func checkOptionalOwnership<T: Ownable>(for resource: T) throws {
        _ = try self.optionalUser().map(to: Void.self) { user in
            guard let authenticatedUser = user else {
                // no token supplied
                throw Abort(.unauthorized)
            }
            
            try authenticatedUser.checkOwnership(for: resource, on: self)
        } 
    }
}
