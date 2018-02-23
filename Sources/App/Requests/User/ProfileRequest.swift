//
//  ProfileRequest.swift
//  App
//
//  Created by Niklas Sauer on 12.02.18.
//

import Foundation
import Vapor
import Validation

struct ProfileRequest: Codable {
    let firstName: String
    let lastName: String
    let birth: Date
    let sex: String?
    let description: String?
    let streetName: String?
    let streetNumber: Int?
    let postalCode: Int?
    let country: String?
}

extension ProfileRequest: Validatable {
    static var validations: Validations = [
        key(\ProfileRequest.firstName): IsCount(1...50),
        key(\ProfileRequest.lastName): IsCount(1...50),
    ]
}

extension ProfileRequest: OptionallyValidatable {
    static var optionalValidations: OptionallyValidatable.Validations = [
        key(\ProfileRequest.sex): IsSex(),
        key(\ProfileRequest.description): IsCount(0...255),
        key(\ProfileRequest.streetName): IsCount(0...50),
        key(\ProfileRequest.country): IsCount(0...50),
    ]
}

extension ProfileRequest: Payload {
    typealias RequestType = ProfileRequest
    
    static var requiredParameters: [Payload.Parameter] = [
        ("firstName", "Niklas"),
        ("lastName", "Sauer"),
        ("birth", Date()),
    ]
    
    static var optionalParameters: [Payload.Parameter] = [
        ("sex", "male"),
        ("description", "Dualer Student"),
        ("streetName", "Ernststraße"),
        ("streetNumber", 12),
        ("postalCode", 63456),
        ("country", "Germany")
    ]
}
