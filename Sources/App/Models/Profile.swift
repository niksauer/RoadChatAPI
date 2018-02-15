//
//  Profile.swift
//  App
//
//  Created by Niklas Sauer on 12.02.18.
//

import Foundation
import Vapor
import FluentSQLite

//enum SexType: String, Codable {
//    case male
//    case female
//}

final class Profile: Content {
    var id: Int?
    var userID: User.ID
    var firstName: String
    var lastName: String
    var birth: Date
    var sex: String?
    var description: String?
    var streetName: String?
    var streetNumber: Int?
    var postalCode: Int?
    var country: String?
    
    
    init(userID: User.ID, firstName: String, lastName: String, birth: Date, sex: String?, description: String?, streetName: String?, streetNumber: Int?, postalCode: Int?, country: String?) {
        self.userID = userID
        self.firstName = firstName
        self.lastName = lastName
        self.birth = birth
        self.sex = sex
        self.description = description
        self.streetName = streetName
        self.streetNumber = streetNumber
        self.postalCode = postalCode
        self.country = country
    }
    
    convenience init(userID: User.ID, profileRequest: ProfileRequest) {
        self.init(userID: userID, firstName: profileRequest.firstName, lastName: profileRequest.lastName, birth: profileRequest.birth, sex: profileRequest.sex, description: profileRequest.description, streetName: profileRequest.streetName, streetNumber: profileRequest.streetNumber, postalCode: profileRequest.postalCode, country: profileRequest.country)
    }
}

extension Profile {
    func publicProfile(privacy: Privacy) -> PublicProfile {
        return PublicProfile(profile: self, privacy: privacy)
    }
    
    struct PublicProfile: Content {
        var firstName: String?
        var lastName: String?
        var birth: Date?
        var sex: String?
        var description: String?
        var streetName: String?
        var streetNumber: Int?
        var postalCode: Int?
        var country: String?
        
        init(profile: Profile, privacy: Privacy) {
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
            
            self.description = profile.description
            
            if privacy.showAddress {
                self.streetName = profile.streetName
                self.streetNumber = profile.streetNumber
                self.postalCode = profile.postalCode
                self.country = profile.country
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
