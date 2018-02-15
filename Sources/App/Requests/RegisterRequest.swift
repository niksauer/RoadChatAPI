//
//  RegisterRequest.swift
//  App
//
//  Created by Niklas Sauer on 07.02.18.
//

import Foundation
import Vapor
import Validation

struct RegisterRequest: Codable {
    let email: String
    let username: String
    let password: String
}

extension RegisterRequest: Validatable {
    static var validations: Validations = [
        key(\RegisterRequest.email): IsEmail(),
        key(\RegisterRequest.username): IsCount(4...) && IsAlphanumeric(),
        key(\RegisterRequest.password): IsCount(8...) && IsASCII()
    ]
}

extension RegisterRequest: OptionallyValidatable {
    static var optionalValidations: OptionallyValidatable.Validations = [:]
}

extension RegisterRequest: RequestBody {
    typealias RequestType = RegisterRequest
    
    static var requiredParameters: Parameters = [
        ("email", "nik.sauer@me.com"),
        ("username", "inik"),
        ("password", "safeharbour")
    ]
    
    static var optionalParameters: Parameters = []
}
