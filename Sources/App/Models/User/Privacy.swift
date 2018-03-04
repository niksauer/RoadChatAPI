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

final class Privacy: Content {
    var id: Int?
    var userID: User.ID
    var shareLocation = false
    var showFirstName = true
    var showLastName = false
    var showBirth = false
    var showSex = true
    var showAddress = false
    var showBiography = true
    
    init(userID: User.ID) {
        self.userID = userID
    }
    
    init(userID: User.ID, shareLocation: Bool, showFirstName: Bool, showLastName: Bool, showBirth: Bool, showSex: Bool, showAddress: Bool, showBiography: Bool) {
        self.userID = userID
        self.shareLocation = shareLocation
        self.showFirstName = showFirstName
        self.showLastName = showLastName
        self.showBirth = showBirth
        self.showSex = showSex
        self.showAddress = showAddress
        self.showBiography = showBiography
    }
    
    convenience init(userID: User.ID, privacyRequest request: PrivacyRequest) {
        self.init(userID: userID, shareLocation: request.shareLocation, showFirstName: request.showFirstName, showLastName: request.showLastName, showBirth: request.showBirth, showSex: request.showSex, showAddress: request.showAddress, showBiography: request.showBiography)
    }
}

extension Privacy {
    func publicPrivacy() -> PublicPrivacy {
        return PublicPrivacy(privacy: self)
    }
    
    struct PublicPrivacy: Content {
        let shareLocation: Bool
        let showFirstName: Bool
        let showLastName: Bool
        let showBirth: Bool
        let showSex: Bool
        let showAddress: Bool
        let showBiography: Bool
        
        init(privacy: Privacy) {
            self.shareLocation = privacy.shareLocation
            self.showFirstName = privacy.showFirstName
            self.showLastName = privacy.showLastName
            self.showBirth = privacy.showBirth
            self.showSex = privacy.showSex
            self.showAddress = privacy.showAddress
            self.showBiography = privacy.showBiography
        }
    }
}

extension Privacy: SQLiteModel, Migration {
    static var idKey: WritableKeyPath<Privacy, Int?> {
        return \Privacy.id
    }
    
    var user: Parent<Privacy, User> {
        return parent(\Privacy.userID)
    }
}
