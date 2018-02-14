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
    var communityRadius: Int = 10
    var trafficRadius: Int = 5
    var showFirstName = true
    var showLastName = false
    var showBirth = false
    var showSex = true
    var showAddress = false
    var showProfession = true
    
    init(userID: User.ID) {
        self.userID = userID
    }
    
    init(userID: User.ID, communityRadius: Int, trafficRadius: Int, showFirstName: Bool, showLastName: Bool, showBirth: Bool, showSex: Bool, showAddress: Bool, showProfession: Bool) {
        self.userID = userID
        self.communityRadius = communityRadius
        self.trafficRadius = trafficRadius
        self.showFirstName = showFirstName
        self.showLastName = showLastName
        self.showBirth = showBirth
        self.showSex = showSex
        self.showAddress = showAddress
        self.showProfession = showProfession
    }
    
    convenience init(userID: User.ID, settingsRequest: SettingsRequest) {
        self.init(userID: userID, communityRadius: settingsRequest.communityRadius, trafficRadius: settingsRequest.trafficRadius, showFirstName: settingsRequest.showFirstName, showLastName: settingsRequest.showLastName, showBirth: settingsRequest.showBirth, showSex: settingsRequest.showSex, showAddress: settingsRequest.showAddress, showProfession: settingsRequest.showProfession)
    }

}

extension Settings {
    func publicSettings() -> PublicSettings {
        return PublicSettings(settings: self)
    }
    
    struct PublicSettings: Content {
        let communityRadius: Int
        let trafficRadius: Int
        let showFirstName: Bool
        let showLastName: Bool
        let showBirth: Bool
        let showSex: Bool
        let showAddress: Bool
        let showProfession: Bool
        
        init(settings: Settings) {
            self.communityRadius = settings.communityRadius
            self.trafficRadius = settings.trafficRadius
            self.showFirstName = settings.showFirstName
            self.showLastName = settings.showLastName
            self.showBirth = settings.showBirth
            self.showSex = settings.showSex
            self.showAddress = settings.showAddress
            self.showProfession = settings.showProfession
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
