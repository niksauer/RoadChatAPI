//
//  Settings.swift
//  App
//
//  Created by Niklas Sauer on 11.02.18.
//

import Foundation
import Vapor
import FluentSQLite

final class Settings: Content {
    var id: Int?
    var userID: User.ID
    var communityRadius: Int = 5
    var trafficRadius: Int = 10
    
    // data sharing options
    var showsFirstName = true
    var showsLastName = false
    var showsBirth = false
    var showsSex = true
    var showsAddress = false
    var showsProfession = true
    
    init(userID: User.ID) {
        self.userID = userID
    }
    
    init(userID: User.ID, communityRadius: Int, trafficRadius: Int, showsFirstName: Bool, showsLastName: Bool, showsBirth: Bool, showsSex: Bool, showsAddress: Bool, showsProfession: Bool) {
        self.userID = userID
        self.communityRadius = communityRadius
        self.trafficRadius = trafficRadius
        self.showsFirstName = showsFirstName
        self.showsLastName = showsLastName
        self.showsBirth = showsBirth
        self.showsSex = showsSex
        self.showsAddress = showsAddress
        self.showsProfession = showsProfession
    }
    
    convenience init(userID: User.ID, settingsRequest: SettingsRequest) {
        self.init(userID: userID, communityRadius: settingsRequest.communityRadius, trafficRadius: settingsRequest.trafficRadius, showsFirstName: settingsRequest.showsFirstName, showsLastName: settingsRequest.showsLastName, showsBirth: settingsRequest.showsBirth, showsSex: settingsRequest.showsSex, showsAddress: settingsRequest.showsAddress, showsProfession: settingsRequest.showsProfession)
    }

}

extension Settings {
    func publicSettings() -> PublicSettings {
        return PublicSettings(settings: self)
    }
    
    struct PublicSettings: Content {
        let communityRadius: Int
        let trafficRadius: Int
        let showsFirstName: Bool
        let showsLastName: Bool
        let showsBirth: Bool
        let showsSex: Bool
        let showsAddress: Bool
        let showsProfession: Bool
        
        init(settings: Settings) {
            self.communityRadius = settings.communityRadius
            self.trafficRadius = settings.trafficRadius
            self.showsFirstName = settings.showsFirstName
            self.showsLastName = settings.showsLastName
            self.showsBirth = settings.showsBirth
            self.showsSex = settings.showsSex
            self.showsAddress = settings.showsAddress
            self.showsProfession = settings.showsProfession
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
