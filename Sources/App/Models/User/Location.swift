//
//  Location.swift
//  App
//
//  Created by Phillip Rust on 21.02.18.
//

import Foundation
import Vapor
import FluentMySQL
import RoadChatKit

extension Location: SQLiteModel, Migration {
    public static var idKey: WritableKeyPath<Location, Int?> {
        return \Location.id
    }
    
    static var entity: String {
        return "location"
    }
}

extension Location.PublicLocation: Content {}

