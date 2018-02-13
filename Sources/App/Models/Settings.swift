//
//  Settings.swift
//  App
//
//  Created by Niklas Sauer on 11.02.18.
//

import Foundation
import Vapor
import FluentSQLite

enum PrivacyType: String, Codable {
    case `private`
    case `public`
}

final class Settings: Content {
    var id: Int?
    var userID: User.ID
    var privacy: String = PrivacyType.private.rawValue
    var communityRadius: Int = 5
    var trafficRadius: Int = 10
    
    init(userID: User.ID) {
        self.userID = userID
    }
    
    init(userID: User.ID, privacy: PrivacyType, communityRadius: Int, trafficRadius: Int) {
        self.userID = userID
        self.privacy = privacy.rawValue
        self.communityRadius = communityRadius
        self.trafficRadius = trafficRadius
    }
    
    convenience init(userID: User.ID, settingsRequest: SettingsRequest) {
        self.init(userID: userID, privacy: settingsRequest.privacy, communityRadius: settingsRequest.communityRadius, trafficRadius: settingsRequest.trafficRadius)
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
    static var idKey: WritableKeyPath<Settings, Int?> {
        return \Settings.id
    }
    
    var user: Parent<Settings, User> {
        return parent(\Settings.userID)
    }
}
