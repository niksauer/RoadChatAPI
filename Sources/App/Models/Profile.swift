//
//  Profile.swift
//  App
//
//  Created by Niklas Sauer on 12.02.18.
//

import Foundation
import Vapor
import FluentSQLite

enum SexType: String, Codable {
    case male
    case female
}

final class Profile: Content {
    var id: Int?
    var userID: User.ID
    var firstName: String
    var lastName: String
    var birth: Date
    var sex: String?
    var streetName: String?
    var streetNumber: Int?
    var postalCode: Int?
    var country: String?
    var profession: String?
    
    init(userID: User.ID, firstName: String, lastName: String, birth: Date, sex: SexType, streetName: String, streetNumber: Int, postalCode: Int, country: String, profession: String) {
        self.userID = userID
        self.sex = sex.rawValue
        self.firstName = firstName
        self.lastName = lastName
        self.birth = birth
        self.streetName = streetName
        self.streetNumber = streetNumber
        self.postalCode = postalCode
        self.country = country
        self.profession = profession
    }
    
    convenience init(userID: User.ID, profileRequest: ProfileRequest) {
        self.init(userID: userID, firstName: profileRequest.firstName, lastName: profileRequest.lastName, birth: profileRequest.birth, sex: profileRequest.sex, streetName: profileRequest.streetName, streetNumber: profileRequest.streetNumber, postalCode: profileRequest.postalCode, country: profileRequest.country, profession: profileRequest.profession)
    }
}

extension Profile {
    func publicProfile(privacy: Settings) -> PublicProfile {
        return PublicProfile(profile: self, privacy: privacy)
    }
    
    struct PublicProfile: Content {
        var firstName: String?
        var lastName: String?
        var birth: Date?
        var sex: String?
        var streetName: String?
        var streetNumber: Int?
        var postalCode: Int?
        var country: String?
        var profession: String?
        
        init(profile: Profile, privacy: Settings) {
            if privacy.showsFirstName {
                self.firstName = profile.firstName
            }
            
            if privacy.showsLastName {
                self.lastName = profile.lastName
            } else if let firstCharacter = profile.lastName.first {
                self.lastName = "\(firstCharacter)."
            }
            
            if privacy.showsBirth {
                self.birth = profile.birth
            }
            
            if privacy.showsSex {
                self.sex = profile.sex
            }
            
            if privacy.showsAddress {
                self.streetName = profile.streetName
                self.streetNumber = profile.streetNumber
                self.postalCode = profile.postalCode
                self.country = profile.country
            }
            
            if privacy.showsProfession {
                self.profession = profile.profession
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
