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
    var sex: String
    var firstName: String
    var lastName: String
    var birth: Date
    var streetName: String
    var streetNumber: Int
    var postalCode: Int
    var country: String
    var profession: String
    
    init(userID: User.ID, sex: SexType, firstName: String, lastName: String, birth: Date, streetName: String, streetNumber: Int, postalCode: Int, country: String, profession: String) {
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
        self.init(userID: userID, sex: profileRequest.sex, firstName: profileRequest.firstName, lastName: profileRequest.lastName, birth: profileRequest.birth, streetName: profileRequest.streetName, streetNumber: profileRequest.streetNumber, postalCode: profileRequest.postalCode, country: profileRequest.country, profession: profileRequest.profession)
    }
}

extension Profile {
    func publicProfile() -> PublicProfile {
        return PublicProfile(profile: self)
    }
    
    struct PublicProfile: Content {
        let sex: String
        let firstName: String
        var lastName: String
        var birth: Date
        var streetName: String
        var streetNumber: Int
        var postalCode: Int
        var country: String
        var profession: String
        
        init(profile: Profile) {
            self.sex = profile.sex
            self.firstName = profile.firstName
            self.lastName = profile.lastName
            self.birth = profile.birth
            self.streetName = profile.streetName
            self.streetNumber = profile.streetNumber
            self.postalCode = profile.postalCode
            self.country = profile.country
            self.profession = profile.profession
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
