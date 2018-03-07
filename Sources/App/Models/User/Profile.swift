//
//  Profile.swift
//  App
//
//  Created by Niklas Sauer on 12.02.18.
//

import Foundation
import Vapor
import FluentSQLite
import RoadChatKit

extension Profile: SQLiteModel, Migration {
    public static var idKey: WritableKeyPath<Profile, Int?> {
        return \Profile.id
    }
    
    static var entity: String {
        return "profile"
    }
    
    var user: Parent<Profile, User> {
        return parent(\Profile.userID)
    }
}

extension Profile.PublicProfile: Content {}
