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
    public static var validations: Validations = [
        key(\ProfileRequest.firstName): IsCount(1...50),
        key(\ProfileRequest.lastName): IsCount(1...50),
    ]
}

extension ProfileRequest: OptionallyValidatable {
    static var optionalValidations: OptionallyValidatable.Validations = [
        key(\ProfileRequest.sex): IsSex(),
        key(\ProfileRequest.biography): IsCount(0...280),
        key(\ProfileRequest.streetName): IsCount(0...50),
        key(\ProfileRequest.country): IsCount(0...50),
    ]
}

extension ProfileRequest: Payload {
    typealias RequestType = ProfileRequest
    
    static var requiredParameters: [Payload.Parameter] = [
        ("firstName", String.self),
        ("lastName", String.self),
        ("birth", Date.self),
    ]
    
    static var optionalParameters: [Payload.Parameter] = [
        ("sex", String.self),
        ("biography", String.self),
        ("streetName", String.self),
        ("streetNumber", Int.self),
        ("postalCode", Int.self),
        ("country", String.self)
    ]
}
