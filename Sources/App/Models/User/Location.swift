//
//  Location.swift
//  App
//
//  Created by Phillip Rust on 21.02.18.
//

import Foundation
import Vapor
import FluentSQLite
import RoadChatKit

extension Location: SQLiteModel, Migration {
    public static var idKey: WritableKeyPath<Location, Int?> {
        return \Location.id
    }
}

extension Location.PublicLocation: Content {}

