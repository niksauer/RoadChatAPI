//
//  CommunityController.swift
//  App
//
//  Created by Niklas Sauer on 06.02.18.
//

import Foundation
import Vapor
import Fluent

/// Controls basic CRUD operations on `CommunityMessage`s.
final class CommunityController {
    
    /// Returns a list of all `CommunityMessage`s.
    func index(_ req: Request) throws -> Future<[CommunityMessage]> {
        return CommunityMessage.query(on: req).all()
    }
    
}
