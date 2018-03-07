//
//  Settings.swift
//  App
//
//  Created by Niklas Sauer on 11.02.18.
//

import Foundation
import Vapor
import FluentMySQL
import RoadChatKit

extension Settings: MySQLModel, Migration {
    public static var idKey: WritableKeyPath<Settings, Int?> {
        return \Settings.id
    }
    
    public static var entity: String {
        return "settings"
    }
    
    var user: Parent<Settings, User> {
        return parent(\Settings.userID)
    }
}

extension Settings.PublicSettings: Content {}
