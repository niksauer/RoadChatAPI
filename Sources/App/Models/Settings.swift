//
//  Settings.swift
//  App
//
//  Created by Niklas Sauer on 11.02.18.
//

import Foundation
import Vapor
import FluentSQLite

enum PrivacyLevel: String, Codable {
    case `private`
    case `public`
}

final class Settings: Content {
    var id: Int?
    var privacy: String = PrivacyLevel.private.rawValue
    var communityRadius: Int = 5
    var trafficRadius: Int = 10
    var userID: User.ID
    
    var user: Parent<Settings, User> {
        return parent(\Settings.userID)
    }

    init(userID: User.ID) {
        self.userID = userID
    }
    
    init(privacy: PrivacyLevel, communityRadius: Int, trafficRadius: Int, userID: User.ID) {
        self.privacy = privacy.rawValue
        self.communityRadius = communityRadius
        self.trafficRadius = trafficRadius
        self.userID = userID
    }
}

extension Settings {
    func publicSettings() -> PublicSettings {
        return PublicSettings(settings: self)
    }
    
    struct PublicSettings: Content {
        let privacy: String
        let communityRadius: Int
        let trafficRadius: Int
        
        init(settings: Settings) {
            self.privacy = settings.privacy
            self.communityRadius = settings.communityRadius
            self.trafficRadius = settings.trafficRadius
        }
    }
}

extension Settings: SQLiteModel, Migration {
    static var idKey: ReferenceWritableKeyPath<Settings, Int?> {
        return \Settings.id
    }
}
