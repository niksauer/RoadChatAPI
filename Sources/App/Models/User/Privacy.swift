//
//  Privacy.swift
//  App
//
//  Created by Niklas Sauer on 14.02.18.
//

import Foundation
import Vapor
import FluentSQLite
import RoadChatKit

extension Privacy: SQLiteModel, Migration {
    public static var idKey: WritableKeyPath<Privacy, Int?> {
        return \Privacy.id
    }
    
    static var entity: String {
        return "privacy"
    }
    
    var user: Parent<Privacy, User> {
        return parent(\Privacy.userID)
    }
}

extension Privacy.PublicPrivacy: Content {}
