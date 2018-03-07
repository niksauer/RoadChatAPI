//
//  Settings.swift
//  App
//
//  Created by Niklas Sauer on 11.02.18.
//

import Foundation
import Vapor
import FluentSQLite
import RoadChatKit

extension Settings: SQLiteModel, Migration {
    public static var idKey: WritableKeyPath<Settings, Int?> {
        return \Settings.id
    }
    
    var user: Parent<Settings, User> {
        return parent(\Settings.userID)
    }
}

extension Settings.PublicSettings: Content {}
