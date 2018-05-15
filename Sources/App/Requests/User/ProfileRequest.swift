//
//  ProfileRequest.swift
//  App
//
//  Created by Niklas Sauer on 12.02.18.
//

import Foundation
import Vapor
import Validation
import RoadChatKit

extension ProfileRequest: Validatable, Reflectable {
    public static func validations() throws -> Validations<ProfileRequest> {
        var validations = Validations(ProfileRequest.self)
        try validations.add(\.firstName, .count(1...50))
        try validations.add(\.lastName, .count(1...50))
        return validations
    }
}

//extension ProfileRequest: OptionallyValidatable {
//    static var optionalValidations: OptionallyValidatable.Validations = [
//        key(\ProfileRequest.sex): IsSex(),
//        key(\ProfileRequest.biography): IsCount(0...255),
//        key(\ProfileRequest.streetName): IsCount(0...50),
//        key(\ProfileRequest.country): IsCount(0...50),
//    ]
//}

extension ProfileRequest: Payload {
    static var requiredParameters: [Payload.Parameter] = [
        ("firstName", String.self),
        ("lastName", String.self),
        ("birth", Date.self),
    ]
    
    static var optionalParameters: [Payload.Parameter] = [
        ("sex", SexType.RawValue.self),
        ("biography", String.self),
        ("streetName", String.self),
        ("streetNumber", Int.self),
        ("postalCode", Int.self),
        ("country", String.self)
    ]
}
