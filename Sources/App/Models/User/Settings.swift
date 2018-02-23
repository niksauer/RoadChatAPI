//
//  Settings.swift
//  App
//
//  Created by Niklas Sauer on 11.02.18.
//

import Foundation
import Vapor
import FluentMySQL

final class Settings: Content {
    var id: Int?
    var userID: User.ID
    var communityRadius: Int = 10
    var trafficRadius: Int = 5
    
    init(userID: User.ID) {
        self.userID = userID
    }
    
    init(userID: User.ID, communityRadius: Int, trafficRadius: Int) {
        self.userID = userID
        self.communityRadius = communityRadius
        self.trafficRadius = trafficRadius
    }
    
    convenience init(userID: User.ID, settingsRequest: SettingsRequest) {
        self.init(userID: userID, communityRadius: settingsRequest.communityRadius, trafficRadius: settingsRequest.trafficRadius)
    }

}

extension Settings {
    func publicSettings() -> PublicSettings {
        return PublicSettings(settings: self)
    }
    
    struct PublicSettings: Content {
        let communityRadius: Int
        let trafficRadius: Int
        
        init(settings: Settings) {
            self.communityRadius = settings.communityRadius
            self.trafficRadius = settings.trafficRadius
        }
    }
}

extension Settings: MySQLModel, Migration {
    static var idKey: WritableKeyPath<Settings, Int?> {
        return \Settings.id
    }
    
    static var entity: String {
        return "settings"
    }
    
    var user: Parent<Settings, User> {
        return parent(\Settings.userID)
    }
}
