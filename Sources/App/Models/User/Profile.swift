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

final class Profile: Content {
    var id: Int?
    var userID: User.ID
    var firstName: String
    var lastName: String
    var birth: Date
    var sex: String?
    var biography: String?
    var streetName: String?
    var streetNumber: Int?
    var postalCode: Int?
    var country: String?
    
    
    init(userID: User.ID, firstName: String, lastName: String, birth: Date, sex: String?, biography: String?, streetName: String?, streetNumber: Int?, postalCode: Int?, country: String?) {
        self.userID = userID
        self.firstName = firstName
        self.lastName = lastName
        self.birth = birth
        self.sex = sex
        self.biography = biography
        self.streetName = streetName
        self.streetNumber = streetNumber
        self.postalCode = postalCode
        self.country = country
    }
    
    convenience init(userID: User.ID, profileRequest request: ProfileRequest) {
        self.init(userID: userID, firstName: request.firstName, lastName: request.lastName, birth: request.birth, sex: request.sex, biography: request.biography, streetName: request.streetName, streetNumber: request.streetNumber, postalCode: request.postalCode, country: request.country)
    }
}

extension Profile {
    func publicProfile(privacy: Privacy, isOwner: Bool) -> PublicProfile {
        return PublicProfile(profile: self, privacy: privacy, isOwner: isOwner)
    }
    
    struct PublicProfile: Content {
        var firstName: String?
        var lastName: String?
        var birth: Date?
        var sex: String?
        var biography: String?
        var streetName: String?
        var streetNumber: Int?
        var postalCode: Int?
        var country: String?
        
        init(profile: Profile, privacy: Privacy, isOwner: Bool) {
            if isOwner {
                self.firstName = profile.firstName
                self.lastName = profile.lastName
                self.birth = profile.birth
                self.sex = profile.sex
                self.biography = profile.biography
                self.streetName = profile.streetName
                self.streetNumber = profile.streetNumber
                self.postalCode = profile.postalCode
                self.country = profile.country
            } else {
                if privacy.showFirstName {
                    self.firstName = profile.firstName
                }
                
                if privacy.showLastName {
                    self.lastName = profile.lastName
                } else if let firstCharacter = profile.lastName.first {
                    self.lastName = "\(firstCharacter)."
                }
                
                if privacy.showBirth {
                    self.birth = profile.birth
                }
                
                if privacy.showSex {
                    self.sex = profile.sex
                }
                
                self.biography = profile.biography
                
                if privacy.showAddress {
                    self.streetName = profile.streetName
                    self.streetNumber = profile.streetNumber
                    self.postalCode = profile.postalCode
                    self.country = profile.country
                }
            }
        }
    }
}

extension Profile: SQLiteModel, Migration {
    static var idKey: WritableKeyPath<Profile, Int?> {
        return \Profile.id
    }
    
    var user: Parent<Profile, User> {
        return parent(\Profile.userID)
    }
}
