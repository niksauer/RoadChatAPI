//
//  Privacy.swift
//  App
//
//  Created by Niklas Sauer on 14.02.18.
//

import Foundation
import Vapor
import FluentMySQL
import RoadChatKit

extension Privacy: MySQLModel, Migration {
    public static var idKey: WritableKeyPath<Privacy, Int?> {
        return \Privacy.id
    }
    
    public static var entity: String {
        return "privacy"
    }
    
    var user: Parent<Privacy, User> {
        return parent(\Privacy.userID)
    }
}

extension Privacy.PublicPrivacy: Content {}
