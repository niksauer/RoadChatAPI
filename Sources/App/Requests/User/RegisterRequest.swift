//
//  RegisterRequest.swift
//  App
//
//  Created by Niklas Sauer on 07.02.18.
//

import Foundation
import Vapor
import Validation
import RoadChatKit

extension RegisterRequest: Validatable, Reflectable {
    public static var validations: Validations = [
        key(\RegisterRequest.email): IsEmail(),
        key(\RegisterRequest.username): IsCount(4...) && IsAlphanumeric(),
        key(\RegisterRequest.password): IsCount(8...) && IsASCII()
    ]
}

extension RegisterRequest: OptionallyValidatable {
    static var optionalValidations: OptionallyValidatable.Validations = [:]
}

extension RegisterRequest: Payload {
    typealias RequestType = RegisterRequest
    
    static var requiredParameters: [Payload.Parameter] = [
        ("email", "nik.sauer@me.com"),
        ("username", "inik"),
        ("password", "safeharbour")
    ]
    
    static var optionalParameters: [Payload.Parameter] = []
}
