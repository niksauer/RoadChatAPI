//
//  Profile.swift
//  App
//
//  Created by Niklas Sauer on 12.02.18.
//

import Foundation
import Vapor
import FluentMySQL
import RoadChatKit

extension Profile: MySQLModel, Migration {
    public static var idKey: WritableKeyPath<Profile, Int?> {
        return \Profile.id
    }
    
    public static var entity: String {
        return "profile"
    }
    
    var user: Parent<Profile, User> {
        return parent(\Profile.userID)
    }
}

extension Profile.PublicProfile: Content {}
