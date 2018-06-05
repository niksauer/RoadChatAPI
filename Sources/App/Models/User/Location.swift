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

extension Location: MySQLModel, Migration {
    public static var idKey: WritableKeyPath<Location, Int?> {
        return \Location.id
    }
    
    public static var entity: String {
        return "Location"
    }
}

extension Location.PublicLocation: Content {}

